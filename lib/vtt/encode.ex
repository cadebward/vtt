defmodule Vtt.Encode do
  @moduledoc false
  alias Vtt.Cue
  alias Vtt.Header

  @spec encode(Header.t()) :: String.t()
  def encode(%Header{} = header) do
    header.values
    |> Enum.map(fn {key, value} ->
      "#{key}:#{value}"
    end)
    |> Enum.join(",")
  end

  @spec encode(Cue.t(), :vtt | :srt, map()) :: String.t()
  def encode(%Cue{} = cue, type, opts \\ %{}) do
    ts =
      fmt_timestamp(cue.start, type) <>
        " --> " <> fmt_timestamp(cue.end, type) <> fmt_settings(cue.settings)

    text =
      if type == :vtt && cue.voice do
        "<v #{cue.voice}>" <> cue.text
      else
        cue.text
      end

    if opts.use_cue_identifiers do
      Enum.join([cue.part, ts, text], "\n")
    else
      Enum.join([ts, text], "\n")
    end
  end

  @hour_ms 3_600_000
  @minute_ms 60_000
  defp fmt_timestamp(milliseconds, type) do
    {hours, ms_wo_hrs} = mod(milliseconds, @hour_ms)
    {minutes, ms_wo_mins} = mod(ms_wo_hrs, @minute_ms)

    hr_and_min =
      [hours, minutes]
      |> Enum.map(&prefix_fmt/1)
      |> Enum.join(":")

    hr_and_min <> ":" <> fmt_seconds(ms_wo_mins, type)
  end

  defp fmt_settings([]), do: ""
  defp fmt_settings(nil), do: ""

  defp fmt_settings(settings) do
    setting_strings =
      settings
      |> Enum.map(fn {key, value} ->
        "#{key}:#{value}"
      end)
      |> Enum.join(" ")

    " #{setting_strings}"
  end

  defp mod(dividend, divisor) do
    remainder = Integer.mod(dividend, divisor)
    quotient = (dividend - remainder) / divisor
    {trunc(quotient), remainder}
  end

  defp prefix_fmt(num) do
    num |> Integer.to_string() |> String.pad_leading(2, "0")
  end

  # Force seconds to have three decimal places and 0 padded in the front
  @second_ms 1000
  defp fmt_seconds(milliseconds, type) do
    [seconds, dec_part] =
      milliseconds
      |> Kernel./(@second_ms)
      |> Float.round(3)
      |> Float.to_string()
      |> String.split(".")

    seconds = String.pad_leading(seconds, 2, "0")
    ms_part = String.pad_trailing(dec_part, 3, "0")

    separator =
      if type == :srt do
        ","
      else
        "."
      end

    seconds <> separator <> ms_part
  end
end
