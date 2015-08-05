-module(inotify).
-export([start/0,
         stop/1
    ]).

start() ->
    inotify_entry:setup(),

    {ok,Port} = port(),
    io:format("......\nStarting cowboy on ~p\n......\n",[Port]),
    Routes    = routes(),
    Dispatch  = cowboy_router:compile(Routes),
    {ok, Pid} = cowboy:start_http(http,
                                _ConnectionPoolSize=10,
                                [{port, Port}],
                                [{env, [{dispatch, Dispatch}]},
                                 {max_keepalive, 50},
                                 %% {onrequest, fun timely_session:on_request/1},
                                 {timeout, 500}
                                ]
                               ),
    {ok,Pid}.

routes() ->

	% {ok,IgnoreList} = application:get_env(inotify, 

    [
     {'_',
        [
            {"/", cowboy_static, {priv_file, inotify, "www/index.html"}},
            {"/entry", inotify_entry, []},
            {"/list", inotify_list_entries, []},
            {"/[...]", cowboy_static, {priv_dir, inotify, "/www"}}
        ]
     }
    ].

port() ->
    {ok,8090}.

stop(Pid) ->
    cowboy:stop_listener(Pid).