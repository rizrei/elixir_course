defmodule WorldChamp do
  @type champ() :: [team()]
  @type team() :: {:team, String.t(), [player()]}
  @type player() :: {:player, String.t(), player_age(), player_rating(), player_health()}

  @type player_age() :: pos_integer()
  @type player_rating() :: pos_integer()
  @type player_health() :: pos_integer()

  @spec sample_champ() :: champ()
  def sample_champ() do
    [
      {
        :team,
        "Crazy Bulls",
        [
          {:player, "Big Bull", 22, 545, 99},
          {:player, "Small Bull", 18, 324, 95},
          {:player, "Bull Bob", 19, 32, 45},
          {:player, "Bill The Bull", 23, 132, 85},
          {:player, "Tall Ball Bull", 38, 50, 50},
          {:player, "Bull Dog", 35, 201, 91},
          {:player, "Bull Tool", 29, 77, 96},
          {:player, "Mighty Bull", 22, 145, 98}
        ]
      },
      {
        :team,
        "Cool Horses",
        [
          {:player, "Lazy Horse", 21, 423, 80},
          {:player, "Sleepy Horse", 23, 101, 35},
          {:player, "Horse Doors", 19, 87, 23},
          {:player, "Rainbow", 21, 200, 17},
          {:player, "HoHoHorse", 20, 182, 44},
          {:player, "Pony", 25, 96, 76},
          {:player, "Hippo", 17, 111, 96},
          {:player, "Hop-Hop", 31, 124, 49}
        ]
      },
      {
        :team,
        "Fast Cows",
        [
          {:player, "Flash Cow", 18, 56, 34},
          {:player, "Cow Bow", 28, 89, 90},
          {:player, "Boom! Cow", 20, 131, 99},
          {:player, "Light Speed Cow", 21, 201, 98},
          {:player, "Big Horn", 23, 38, 93},
          {:player, "Milky", 25, 92, 95},
          {:player, "Jumping Cow", 19, 400, 98},
          {:player, "Cow Flow", 18, 328, 47}
        ]
      },
      {
        :team,
        "Fury Hens",
        [
          {:player, "Ben The Hen", 57, 403, 83},
          {:player, "Hen Hen", 20, 301, 56},
          {:player, "Son of Hen", 21, 499, 43},
          {:player, "Beak", 22, 35, 96},
          {:player, "Superhen", 27, 12, 26},
          {:player, "Henman", 20, 76, 38},
          {:player, "Farm Hen", 18, 131, 47},
          {:player, "Henwood", 40, 198, 77}
        ]
      },
      {
        :team,
        "Extinct Monsters",
        [
          {:player, "T-Rex", 21, 999, 99},
          {:player, "Velociraptor", 29, 656, 99},
          {:player, "Giant Mammoth", 30, 382, 99},
          {:player, "The Big Croc", 42, 632, 99},
          {:player, "Huge Pig", 18, 125, 98},
          {:player, "Saber-Tooth", 19, 767, 97},
          {:player, "Beer Bear", 24, 241, 99},
          {:player, "Pure Horror", 31, 90, 43}
        ]
      }
    ]
  end

  @spec get_stat(champ()) :: {integer(), integer(), number(), number()}
  def get_stat(champ) do
    players = Enum.flat_map(champ, fn {:team, _, players} -> players end)

    {count, total_age, total_rating} =
      Enum.reduce(players, {0, 0, 0}, fn {:player, _, age, rating, _}, {c, a, r} ->
        {c + 1, a + age, r + rating}
      end)

    {
      length(champ),
      count,
      total_age / count,
      total_rating / count
    }
  end

  @player_min_health 50
  @team_min_players_count 5

  @spec examine_champ(champ()) :: champ()
  def examine_champ(champ) do
    champ
    |> Enum.map(fn {:team, name, players} ->
      {:team, name, Enum.filter(players, &players_health_filter/1)}
    end)
    |> Enum.filter(fn {:team, _, players} -> length(players) >= @team_min_players_count end)
  end

  defp players_health_filter({:player, _, _, _, health}) when health < @player_min_health,
    do: false

  defp players_health_filter(_), do: true

  @pair_min_rating 600

  @spec make_pairs(team(), term()) :: [{String.t(), String.t()}]
  def make_pairs({:team, _, t1_players}, {:team, _, t2_players}) do
    for {:player, p1_name, _, p1_rating, _} <- t1_players,
        {:player, p2_name, _, p2_rating, _} <- t2_players,
        p1_rating + p2_rating > @pair_min_rating do
      {p1_name, p2_name}
    end
  end
end
