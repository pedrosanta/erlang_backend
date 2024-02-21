
-module(sessionUtils).

-compile([export_all]).

start(ServerName, {Module,Function,Args}) ->
    global:trans({ServerName, ServerName},
        fun() ->
            case global:whereis_name(ServerName) of
                undefined ->
                    Pid = spawn(Module, Function, Args),
                    global:register_name(ServerName, Pid),
                    Pid;
                _ ->
                    ok
            end
        end).

stop(ServerName) ->
    global:trans({ServerName, ServerName},
		 fun() ->
			 case global:whereis_name(ServerName) of
			     undefined ->
				 ok;
			     _ ->
				 global:send(ServerName, shutdown)
			 end
		 end).

start_monitor(HeartbeatMonitorName, {Module,Function,Args}) ->
global:trans({HeartbeatMonitorName, HeartbeatMonitorName},
    fun() ->
        case global:whereis_name(HeartbeatMonitorName) of
            undefined ->
                Pid = spawn(Module, Function, Args),
                global:register_name(HeartbeatMonitorName, Pid),
                Pid;
            _ ->
                io:format("restarting monitor"),
                stop_monitor(HeartbeatMonitorName),
                Pid = spawn(Module, Function, Args),
                global:register_name(HeartbeatMonitorName, Pid),
                Pid
        end
    end).

stop_monitor(HeartbeatMonitorName) ->
global:trans({HeartbeatMonitorName, HeartbeatMonitorName},
        fun() ->
            case global:whereis_name(HeartbeatMonitorName) of
                undefined ->
                ok;
                _ ->
                exit(HeartbeatMonitorName,shutdown)
            end
        end).

