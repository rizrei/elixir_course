alias MyMusicBand.{Band, Drummer, Guitarist, Vocalist}

{:ok, vocalist} =
  Vocalist.init([
    :"A-a-a",
    :"O-o-o",
    :" ",
    :"A-a-a",
    :Wooo,
    :" ",
    :"E-e-e",
    :"O-o-o",
    :Wooo,
    :" ",
    :"O-o-o",
    :Wooo
  ])

{:ok, guitarist} =
  Guitarist.init([
    :A,
    :D,
    :" ",
    :A,
    :E,
    :" ",
    :E,
    :D,
    :A
  ])

{:ok, drummer} =
  Drummer.init([
    :BOOM,
    :Ts,
    :Ts,
    :Doom,
    :Ts,
    :Ts
  ])

band =
  Band.init()
  |> Band.add_player(vocalist)
  |> Band.add_player(guitarist)
  |> Band.add_player(drummer)
