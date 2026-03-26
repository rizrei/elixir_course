defmodule MyMusicBand.Model.Sound do
  @moduledoc """
  Sound module with types and validation function
   - defines types for vocal, guitar and drum sounds
   - defines a function validate/2, which takes a list of sounds and a list of allowed sounds and returns {:ok, sounds} if all sounds are valid or {:error, [{pos_integer(), sound()}]} if there are invalid sounds, where pos_integer() is the position of the invalid sound in the input list (starting from 1) and sound() is the invalid sound itself
  """

  @type silence() :: :" "

  @type note_a() :: :"A-a-a"
  @type note_c() :: :"O-o-o"
  @type note_e() :: :"E-e-e"
  @type note_g() :: :Wooo
  @type vocal_sound() :: note_a() | note_c() | note_e() | note_g() | silence()

  @type accord_a() :: :A
  @type accord_d() :: :D
  @type accord_e() :: :E
  @type guitar_sound() :: accord_a() | accord_d() | accord_e() | silence()

  @type kick() :: :BOOM
  @type snare() :: :Doom
  @type hi_hat() :: :Ts
  @type drum_sound() :: kick() | snare() | hi_hat() | silence()

  @type sound() :: vocal_sound() | guitar_sound() | drum_sound()

  @spec validate([sound()], list()) :: {:ok, [sound()]} | {:error, [{pos_integer(), sound()}]}
  def validate(sounds, allowed_sounds) do
    sounds
    |> Stream.with_index(1)
    |> Stream.map(fn {sound, position} -> {position, sound} end)
    |> Stream.filter(fn {_, sound} -> sound not in allowed_sounds end)
    |> Enum.to_list()
    |> then(fn
      [] -> {:ok, sounds}
      [_ | _] = invalid_sounds -> {:error, invalid_sounds}
    end)
  end
end
