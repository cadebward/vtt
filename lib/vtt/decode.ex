defmodule Vtt.Decode do
  @moduledoc false

  alias Vtt.Cue
  alias Vtt.Header

  @header_regex ~r/^(\S*?:\S*?)(,\S*?:\S*?)*$/

  def parse(enum_content) do
    parsed =
      enum_content
      |> Stream.map(fn line -> Regex.replace(~r/#.*/, line, "") end)
      |> Stream.map(&String.trim/1)
      |> Stream.reject(&(&1 in ["WEBVTT"]))
      |> Stream.chunk_while(%Cue{}, &parse_chunk/2, &parse_chunk_after/1)
      |> Stream.filter(&full_chunk?/1)
      |> Enum.to_list()

    cues = Enum.filter(parsed, &match?(%Cue{}, &1))
    use_cue_identifiers? = Enum.all?(cues, &(&1.part > 0))

    %Vtt{
      use_cue_identifiers: use_cue_identifiers?,
      headers: Enum.filter(parsed, &match?(%Header{}, &1)),
      cues: cues
    }
  end

  defp parse_chunk(line, acc) do
    acc =
      cond do
        Regex.match?(~r/^\d+$/, line) ->
          %Cue{acc | part: String.to_integer(line)}

        is_nil(acc.part) and header?(line) ->
          values =
            line
            |> String.split(",")
            |> Enum.map(fn kv_pair_string ->
              [key, value] = String.split(kv_pair_string, ":", parts: 2)
              {key, value}
            end)

          %Header{values: values}

        is_nil(acc.part) and timestamps?(line) ->
          {start_ts, end_ts, settings} = parse_cue_timings(line)
          %Cue{acc | start: start_ts, end: end_ts, part: 0, settings: settings}

        not is_nil(acc.part) and timestamps?(line) ->
          {start_ts, end_ts, settings} = parse_cue_timings(line)

          %Cue{acc | start: start_ts, end: end_ts, settings: settings}

        # Text content should be on one line and the other stuff should have appeared
        not is_nil(acc.part) and not is_nil(acc.start) and not is_nil(acc.end) and line != "" ->
          {voice, text} = parse_text(line)
          %Cue{acc | text: maybe_append_text(acc.text, text), voice: voice}

        true ->
          acc
      end

    if full_chunk?(acc, line) do
      {:cont, acc, %Cue{}}
    else
      {:cont, acc}
    end
  end

  defp maybe_append_text(nil, text), do: text
  defp maybe_append_text(previous_line, text), do: Enum.join([previous_line, text], "\n")

  defp parse_chunk_after(acc), do: {:cont, acc, %Cue{}}

  defp full_chunk?(%Header{}), do: true

  defp full_chunk?(%Cue{part: part, start: start, end: ts_end, text: text}) do
    not is_nil(part) and not is_nil(start) and not is_nil(ts_end) and not is_nil(text)
  end

  defp full_chunk?(%Cue{part: part, start: start, end: ts_end, text: text}, line) do
    not is_nil(part) and not is_nil(start) and not is_nil(ts_end) and not is_nil(text) and
      line == ""
  end

  defp full_chunk?(%Header{}, _), do: true

  defp header?(line) do
    Regex.match?(@header_regex, line)
  end

  @ts_pattern ~S"(?:(\d{2,}):)?(\d{2}):(\d{2})\.(\d{3})"
  @line_regex ~r/#{@ts_pattern} --> #{@ts_pattern}/
  @ts_regex ~r/#{@ts_pattern}/

  # 00:00:00.000 --> 00:01:01.000
  defp timestamps?(line) do
    Regex.match?(@line_regex, line)
  end

  @annotation_space_regex ~r/[ \t]/
  defp parse_text("<v" <> line) do
    [voice, text] = String.split(line, ">", parts: 2)
    [_, voice] = String.split(voice, @annotation_space_regex, parts: 2)
    {voice, text}
  end

  defp parse_text(text), do: {nil, text}

  defp parse_cue_timings(line) do
    [start_ts, _separator, end_ts | settings] = Regex.split(~r/[ \t]/, line)
    {parse_timestamp(start_ts), parse_timestamp(end_ts), parse_settings(settings)}
  end

  defp parse_timestamp(ts) do
    [hour, minute, second, millisecond] = Regex.run(@ts_regex, ts, capture: :all_but_first)

    case hour do
      "" -> 0
      hour -> String.to_integer(hour) * 3_600_000
    end +
      String.to_integer(minute) * 60_000 +
      String.to_integer(second) * 1_000 +
      String.to_integer(millisecond)
  end

  defp parse_settings([]), do: []

  defp parse_settings(settings) do
    for setting <- settings do
      [key, value] = String.split(setting, ":")
      {key, value}
    end
  end
end
