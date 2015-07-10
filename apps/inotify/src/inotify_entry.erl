-module(inotify_entry).
-export([init/2]).
-export([allowed_methods/2]).
-export([content_types_provided/2]).
-export([content_types_accepted/2]).
-export([hello_to_text/2]).

-export([setup/0,
		 create_table/0,
		 create_entry/2]).

-record(?MODULE, {now,
				  dir,
				  actions,
				  file
				 }).

init(Req, Opts) ->
	{cowboy_rest, Req, Opts}.

allowed_methods(Req, State) ->
	{[<<"GET">>, <<"POST">>], Req, State}.

content_types_provided(Req, State) ->
	{[{<<"text/plain">>,hello_to_text}], Req, State}.
	
content_types_accepted(Req, State) ->
	{[{{<<"text">>, <<"plain">>, []}, create_entry}], Req, State}.
			
create_entry(Req, State) ->
	N = erlang:now(),
	{ok,Body,Req1} = cowboy_req:body(Req),
	Str = binary_to_list(Body),
	[Dir,Actions,File] = string:tokens(Str, " "),
	case File =:= "erlang.log.1" of 
		true ->
			{true, Req1, State};
		false ->
			ok=
			mnesia:dirty_write(?MODULE,#?MODULE{now=N,
												dir=Dir,
												actions=Actions,
												file=File}),
			{true, Req1, State}
	end.

hello_to_text(Req, State) ->
	{<<"text">>, Req, State}.
	
setup() ->
	mnesia:stop(),
	mnesia:create_schema([node()]),
	mnesia:start(),
	create_table().
	
create_table() ->
    try
        mnesia:table_info(?MODULE,attributes)
    catch
        exit:{aborted,{no_exists,?MODULE,attributes}} ->
            {atomic,ok} =
                mnesia:create_table(
                        ?MODULE,
                        [{type,set},
                         {ram_copies,[node()]},
                         {attributes,record_info(fields, ?MODULE)},
                         {majority, true}
                       ]);
        C:E ->
            throw({stop,[{c,C},{e,E}]})
    end.