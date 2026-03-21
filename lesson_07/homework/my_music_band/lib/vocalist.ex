defmodule MyMusicBand.Vocalist do
  @moduledoc """
  Vocalist struct and functions
   - Vocalist struct has only one field - pattern, which is a list of sounds
   - Vocalist.init/1 takes a list of sounds and returns {:ok, vocalist} or {:error, [{pos_integer(), sound()}]} if there are invalid sounds
   - Vocalist implements Musician protocol, which has only one function - next/1, which returns {sound, vocalist} tuple, where sound is the next sound in the pattern and vocalist is the updated vocalist with the pattern shifted by one position
  """

  alias MyMusicBand.Model.Sound

  @enforce_keys [:pattern]
  defstruct [:pattern]

  @type t :: %__MODULE__{pattern: [Sound.vocal_sound()]}

  @allowed_sounds [:"A-a-a", :"O-o-o", :"E-e-e", :Wooo, :" "]

  @spec init([Sound.sound()]) :: {:ok, t()} | {:error, [{pos_integer(), Sound.sound()}]}
  def init(sounds) do
    case Sound.validate(sounds, @allowed_sounds) do
      {:ok, sounds} -> {:ok, %__MODULE__{pattern: sounds}}
      error -> error
    end
  end

  @spec next(t()) :: {Sound.vocal_sound(), t()}
  def next(%__MODULE__{} = vocalist), do: MyMusicBand.Protocols.Musician.next(vocalist)
end
