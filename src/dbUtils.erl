
-module(dbUtils).

-compile([export_all]).

fill_list_with_null(Players) ->
    case length(Players) of
        4 -> 
            io:format("~p~n",[length(Players)]),
            Players;
        _ -> 
            io:format("~p~n",[length(Players)]),
            NewPlayers = lists:append(Players, ["null"]),
            fill_list_with_null(NewPlayers)
    end.
