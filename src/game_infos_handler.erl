-module(game_infos_handler).
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
        {ok, _, Req5} ->
            processBody(Req5)
    catch
        _Error:_Reason ->
            processBody(Req3)
    end,
    {ok, Req4, State}.


processBody(Req0) ->
    RegisteredNames = global:registered_names(),
    ServerProcesses = [atom_to_list(Name) || Name <- RegisteredNames, re:run(atom_to_list(Name), "^Server_\\d+$") /= nomatch],
    case ServerProcesses of
    [] ->
        ListaDeProcessos = list_to_binary("{\n\t\"Error\":\"none\"\n}"),
        cowboy_req:reply(200, #{<<"content-type">> => <<"application/json; charset=utf-8">>}, ListaDeProcessos, Req0);
    _ ->
        ResultsList = lists:map(
        fun(ServerProcess) ->
            ServerProcessReference = list_to_atom(ServerProcess),
            global:send(ServerProcessReference,{get_number_of_players, self()}),
            receive 
            {number_of_players, PlayersOnline} ->
                lists:concat(["\n\t\"",ServerProcess,"\":",PlayersOnline,","])
            after 
            5000 -> % Set a timeout (e.g., 5 seconds) for receiving responses
                "No response"
            end
        end,
        ServerProcesses
        ),
        Aux = lists:sublist(ResultsList,string:len(ResultsList)-1)++string:slice(lists:last(ResultsList),0,string:len(lists:last(ResultsList))-1),
        ListaDeProcessos = list_to_binary(lists:concat(["{",Aux,"}"])),
        cowboy_req:reply(200, #{<<"content-type">> => <<"application/json; charset=utf-8">>}, ListaDeProcessos, Req0)
    end.