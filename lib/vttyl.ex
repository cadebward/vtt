defmodule Vtt do
  @moduledoc """
  Encoding and decoding VTT files
  """

  alias Vtt.Encode
  alias Vtt.Decode
  alias Vtt.Vtt

  @doc """
  Parse a string.

  This drops badly formatted vtt files.

  This returns a stream so you decide how to handle it!
  """
  @doc since: "0.1.0"
  @spec parse(String.t()) :: Enumerable.t()
  def parse(content) do
    content
    |> String.splitter("\n")
    |> Decode.parse()
  end

  @doc """
  Encodes a list of parts into a vtt file.
  """
  @doc since: "0.1.0"
  @spec encode([Vtt.t()]) :: String.t()
  def encode(%Vtt{headers: headers, cues: cues} = vtt) do
    opts =
      [use_cue_identifiers: vtt.use_cue_identifiers]
      |> Enum.into(%{})

    headers = Enum.join(["WEBVTT" | Enum.map(headers, &Encode.encode_part/1)], "\n")
    cues = Enum.join(Enum.map(cues, &Encode.encode_part(&1, :vtt, opts)), "\n\n")

    Enum.join([headers, cues], "\n\n") <> "\n"
  end
end
