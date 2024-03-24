-module(logs_handler).
-import(string,[concat/2]).

-export([init/2]).

init(Req0, State) ->
    Req1 = cowboy_req:set_resp_header(<<"access-control-allow-methods">>, <<"GET, OPTIONS">>, Req0),
    Req2 = cowboy_req:set_resp_header(<<"access-control-allow-origin">>, <<"*">>, Req1),
    Req3 = cowboy_req:set_resp_header(<<"access-control-allow-headers">>, <<"*">>, Req2),
    Req4 = try
        <<"POST">> = cowboy_req:method(Req3), % Assert supported type
        true = cowboy_req:has_body(Req3),
        cowboy_req:read_body(Req3) of
        {ok, PostBody, Req5} ->
            processBody(PostBody, Req5)
    catch
        _Error:_Reason ->
            Output= list_to_binary(lists:concat(["Bad Request,",<<_Reason>>])),
            cowboy_req:reply(400, #{<<"content-type">> => <<"application/json; charset=utf-8">>}, Output, Req3)
    end,
    {ok, Req4, State}.


processBody(PostBody, Req0) ->
    case jsone:decode(PostBody, [{object_format, map}]) of
    #{<<"serverId">> := ServerId} ->
        get_game_logs(list_to_atom(binary_to_list(ServerId)),Req0);
    _ ->
        cowboy_req:reply(400, #{<<"content-type">> => <<"application/json; charset=utf-8">>}, <<"Invalid or missing parameter">>, Req0)
    end.


get_game_logs(SessionName, Req0) ->
    try
        Messages = localDB:db_get_logs(SessionName),
        case Messages of
            [] ->
                cowboy_req:reply(200,#{<<"content-type">> => <<"application/json; charset=utf-8">>},list_to_binary(lists:concat(["{","}"])), Req0);
            _Else ->
                MessagesList = lists:map(fun(Message) -> 
                    lists:concat([Message,",\n\t"])
                    end, 
                    Messages
                ),
                Aux = lists:sublist(MessagesList,string:len(MessagesList)-1)++string:slice(lists:last(MessagesList),0,string:len(lists:last(MessagesList))-3),
                Reply = list_to_binary(lists:concat(["{",Aux,"}"])),
                cowboy_req:reply(200,#{<<"content-type">> => <<"application/json; charset=utf-8">>},Reply, Req0)
        end
    catch
        _Reason ->
            cowboy_req:reply(400, #{<<"content-type">> => <<"application/json; charset=utf-8">>}, "{\"Error getting game logs\": \"\"}" , Req0)
    end.
    
    