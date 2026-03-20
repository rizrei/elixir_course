defmodule MyMusicBand.Drummer do
  @moduledoc """
  Drummer struct and functions
   - Drummer struct has only one field - pattern, which is a list of sounds
   - Drummer.init/1 takes a list of sounds and returns {:ok, drummer} or {:error, [{pos_integer(), sound()}]} if there are invalid sounds
   - Drummer implements Musician protocol, which has only one function - next/1, which returns {sound, drummer} tuple, where sound is the next sound in the pattern and drummer is the updated drummer with the pattern shifted by one position
  """

  alias MyMusicBand.Model.Sound

  @enforce_keys [:pattern]
  defstruct [:pattern]

  @type t :: %__MODULE__{pattern: [Sound.drum_sound()]}

  @allowed_sounds [:BOOM, :Doom, :Ts, :" "]

  @spec init([Sound.sound()]) :: {:ok, t()} | {:error, [{pos_integer(), Sound.sound()}]}
  def init(sounds) do
    case Sound.validate(sounds, @allowed_sounds) do
      {:ok, sounds} -> {:ok, %__MODULE__{pattern: sounds}}
      error -> error
    end
  end

  @spec next(t()) :: {Sound.drum_sound(), t()}
  def next(%__MODULE__{} = drummer), do: MyMusicBand.Protocols.Musician.next(drummer)
end
