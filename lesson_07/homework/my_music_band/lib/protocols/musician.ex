defprotocol MyMusicBand.Protocols.Musician do
  @moduledoc """
  Protocol for musicians
  """

  @doc "iterates through musician's pattern"
  def next(musician)
end

defimpl MyMusicBand.Protocols.Musician,
  for: [MyMusicBand.Drummer, MyMusicBand.Guitarist, MyMusicBand.Vocalist] do
  alias MyMusicBand.Band

  @spec next(Band.musician()) :: {MyMusicBand.Model.Sound.sound(), Band.musician()}
  def next(%{pattern: [sound | sounds]} = musician) do
    {sound, %{musician | pattern: sounds ++ [sound]}}
  end
end

defimpl MyMusicBand.Protocols.Musician, for: MyMusicBand.Band do
  @spec next(MyMusicBand.Band.t()) :: {[MyMusicBand.Model.Sound.sound()], MyMusicBand.Band.t()}
  def next(%{musicians: musicians} = band) do
    {sounds, musicians} =
      musicians
      |> Enum.map(&MyMusicBand.Protocols.Musician.next/1)
      |> Enum.unzip()

    {Enum.reverse(sounds), %{band | musicians: musicians}}
  end
end
