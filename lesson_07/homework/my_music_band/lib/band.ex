defmodule MyMusicBand.Band do
  @moduledoc """
  Band struct and functions
   - Band struct has only one field - musicians, which is a list of musicians (drummer, guitarist, vocalist)
   - Band.init/0 returns {:ok, band}
   - Band.add_player/2 takes a band and a musician and returns an updated band with the musician added to the musicians list
   - Band implements Musician protocol, which has only one function - next/1, which returns {sounds, band} tuple, where sounds is a list of the next sounds of all musicians in the band and band is the updated band with all musicians' patterns shifted by one position
  """

  alias MyMusicBand.{Drummer, Guitarist, Vocalist}

  @enforce_keys [:musicians]
  defstruct [:musicians]

  @type t :: %__MODULE__{musicians: [musician()]}
  @type musician() :: Drummer.t() | Guitarist.t() | Vocalist.t()

  @spec init() :: t()
  def init, do: %__MODULE__{musicians: []}

  @spec add_player(t(), musician()) :: t()
  def add_player(%__MODULE__{musicians: musicians} = band, musician),
    do: %{band | musicians: [musician | musicians]}

  @spec next(t()) :: {[MyMusicBand.Model.Sound.sound()], t()}
  def next(%__MODULE__{} = band), do: MyMusicBand.Protocols.Musician.next(band)
end
