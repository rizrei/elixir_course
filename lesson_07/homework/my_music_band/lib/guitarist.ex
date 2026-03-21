defmodule MyMusicBand.Guitarist do
  @moduledoc """
  Guitarist struct and functions
   - Guitarist struct has only one field - pattern, which is a list of sounds
   - Guitarist.init/1 takes a list of sounds and returns {:ok, guitarist} or {:error, [{pos_integer(), sound()}]} if there are invalid sounds
   - Guitarist implements Musician protocol, which has only one function - next/1, which returns {sound, guitarist} tuple, where sound is the next sound in the pattern and guitarist is the updated guitarist with the pattern shifted by one position
  """

  alias MyMusicBand.Model.Sound

  @enforce_keys [:pattern]
  defstruct [:pattern]

  @type t :: %__MODULE__{pattern: [Sound.guitar_sound()]}

  @allowed_sounds [:A, :D, :E, :" "]

  @spec init([Sound.sound()]) :: {:ok, t()} | {:error, [{pos_integer(), Sound.sound()}]}
  def init(sounds) do
    case Sound.validate(sounds, @allowed_sounds) do
      {:ok, sounds} -> {:ok, %__MODULE__{pattern: sounds}}
      error -> error
    end
  end

  @spec next(t()) :: {Sound.guitar_sound(), t()}
  def next(%__MODULE__{} = guitarist), do: MyMusicBand.Protocols.Musician.next(guitarist)
end
