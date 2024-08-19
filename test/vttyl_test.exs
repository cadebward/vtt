defmodule VttylTest do
  @moduledoc false

  use ExUnit.Case, async: true

  doctest Vttyl

  alias Vttyl.Header
  alias Vttyl.Vtt

  test "parses a basic vtt" do
    vtt = """
    WEBVTT

    1
    00:00:04.047 --> 00:00:09.135
    line 1

    2
    00:00:10.010 --> 00:00:10.638
    line 2

    3
    00:00:12.722 --> 00:00:13.473
    line 3
    """

    %Vtt{headers: [], cues: cues} = Vttyl.parse(vtt)
    assert Enum.count(cues) == 3

    assert cues == [
             %Vttyl.Part{
               start: 4047,
               end: 9135,
               text: "line 1",
               part: 1,
               voice: nil,
               settings: []
             },
             %Vttyl.Part{
               start: 10010,
               end: 10638,
               text: "line 2",
               part: 2,
               voice: nil,
               settings: []
             },
             %Vttyl.Part{
               start: 12722,
               end: 13473,
               text: "line 3",
               part: 3,
               voice: nil,
               settings: []
             }
           ]
  end

  test "encodes basic vtt" do
    encoded =
      %Vtt{
        headers: [],
        cues: [
          %Vttyl.Part{
            start: 4047,
            end: 9135,
            text: "line 1",
            part: 1,
            voice: nil,
            settings: []
          },
          %Vttyl.Part{
            start: 10010,
            end: 10638,
            text: "line 2",
            part: 2,
            voice: nil,
            settings: []
          },
          %Vttyl.Part{
            start: 12722,
            end: 13473,
            text: "line 3",
            part: 3,
            voice: nil,
            settings: []
          }
        ]
      }
      |> Vttyl.encode()

    expected = """
    WEBVTT

    1
    00:00:04.047 --> 00:00:09.135
    line 1

    2
    00:00:10.010 --> 00:00:10.638
    line 2

    3
    00:00:12.722 --> 00:00:13.473
    line 3
    """

    assert encoded == expected
  end

  test "parses vtt headers" do
    vtt = """
    WEBVTT
    X-TIMESTAMP-MAP=LOCAL:00:00:00.000,MPEGTS:900000

    1
    00:00:04.047 --> 00:00:09.135
    line 1

    2
    00:00:10.010 --> 00:00:10.638
    line 2

    3
    00:00:12.722 --> 00:00:13.473
    line 3
    """

    %Vtt{headers: headers, cues: cues} = Vttyl.parse(vtt)
    assert Enum.count(cues) == 3
    assert Enum.count(headers) == 1

    assert Enum.at(headers, 0) == %Header{
             values: [{"X-TIMESTAMP-MAP=LOCAL", "00:00:00.000"}, {"MPEGTS", "900000"}]
           }
  end

  test "encodes vtt with headers" do
    encoded =
      %Vttyl.Vtt{
        headers: [
          %Vttyl.Header{
            values: [{"X-TIMESTAMP-MAP=LOCAL", "00:00:00.000"}, {"MPEGTS", "900000"}]
          }
        ],
        cues: [
          %Vttyl.Part{
            start: 4047,
            end: 9135,
            text: "line 1",
            part: 1,
            voice: nil,
            settings: []
          },
          %Vttyl.Part{
            start: 10010,
            end: 10638,
            text: "line 2",
            part: 2,
            voice: nil,
            settings: []
          },
          %Vttyl.Part{
            start: 12722,
            end: 13473,
            text: "line 3",
            part: 3,
            voice: nil,
            settings: []
          }
        ]
      }
      |> Vttyl.encode()

    expected = """
    WEBVTT
    X-TIMESTAMP-MAP=LOCAL:00:00:00.000,MPEGTS:900000

    1
    00:00:04.047 --> 00:00:09.135
    line 1

    2
    00:00:10.010 --> 00:00:10.638
    line 2

    3
    00:00:12.722 --> 00:00:13.473
    line 3
    """

    assert encoded == expected
  end

  test "parses missing cue numbers" do
    vtt = """
    WEBVTT

    00:00:04.047 --> 00:00:09.135
    line 1

    00:00:10.010 --> 00:00:10.638
    line 2

    00:00:12.722 --> 00:00:13.473
    line 3
    """

    %Vtt{headers: [], cues: cues, use_cue_identifiers: false} = Vttyl.parse(vtt)
    assert Enum.count(cues) == 3

    assert cues == [
             %Vttyl.Part{
               start: 4047,
               end: 9135,
               text: "line 1",
               part: 0,
               voice: nil,
               settings: []
             },
             %Vttyl.Part{
               start: 10010,
               end: 10638,
               text: "line 2",
               part: 0,
               voice: nil,
               settings: []
             },
             %Vttyl.Part{
               start: 12722,
               end: 13473,
               text: "line 3",
               part: 0,
               voice: nil,
               settings: []
             }
           ]
  end

  test "encodes missing cue numbers" do
    encoded =
      %Vttyl.Vtt{
        use_cue_identifiers: false,
        headers: [],
        cues: [
          %Vttyl.Part{
            start: 4047,
            end: 9135,
            text: "line 1",
            part: 0,
            voice: nil,
            settings: []
          },
          %Vttyl.Part{
            start: 10010,
            end: 10638,
            text: "line 2",
            part: 0,
            voice: nil,
            settings: []
          },
          %Vttyl.Part{
            start: 12722,
            end: 13473,
            text: "line 3",
            part: 0,
            voice: nil,
            settings: []
          }
        ]
      }
      |> Vttyl.encode()

    expected = """
    WEBVTT

    00:00:04.047 --> 00:00:09.135
    line 1

    00:00:10.010 --> 00:00:10.638
    line 2

    00:00:12.722 --> 00:00:13.473
    line 3
    """

    assert encoded == expected
  end

  test "parses cue settings" do
    vtt = """
    WEBVTT

    00:00:04.047 --> 00:00:09.135 align:middle line:85% position:50% size:40%
    line 1

    00:00:10.010 --> 00:00:10.638 align:center
    line 2

    00:00:12.722 --> 00:00:13.473
    line 3
    """

    %Vtt{headers: [], cues: cues} = Vttyl.parse(vtt)

    assert Enum.count(cues) == 3

    assert cues == [
             %Vttyl.Part{
               start: 4047,
               end: 9135,
               text: "line 1",
               part: 0,
               voice: nil,
               settings: [
                 {"align", "middle"},
                 {"line", "85%"},
                 {"position", "50%"},
                 {"size", "40%"}
               ]
             },
             %Vttyl.Part{
               start: 10010,
               end: 10638,
               text: "line 2",
               part: 0,
               voice: nil,
               settings: [{"align", "center"}]
             },
             %Vttyl.Part{
               start: 12722,
               end: 13473,
               text: "line 3",
               part: 0,
               voice: nil,
               settings: []
             }
           ]
  end

  test "encodes cue settings" do
    encoded =
      %Vttyl.Vtt{
        use_cue_identifiers: false,
        headers: [],
        cues: [
          %Vttyl.Part{
            start: 4047,
            end: 9135,
            text: "line 1",
            part: 0,
            voice: nil,
            settings: [
              {"align", "middle"},
              {"line", "85%"},
              {"position", "50%"},
              {"size", "40%"}
            ]
          },
          %Vttyl.Part{
            start: 10010,
            end: 10638,
            text: "line 2",
            part: 0,
            voice: nil,
            settings: [{"align", "center"}]
          },
          %Vttyl.Part{
            start: 12722,
            end: 13473,
            text: "line 3",
            part: 0,
            voice: nil,
            settings: []
          }
        ]
      }
      |> Vttyl.encode()

    expected = """
    WEBVTT

    00:00:04.047 --> 00:00:09.135 align:middle line:85% position:50% size:40%
    line 1

    00:00:10.010 --> 00:00:10.638 align:center
    line 2

    00:00:12.722 --> 00:00:13.473
    line 3
    """

    assert encoded == expected
  end

  test "parses voice" do
    vtt = """
    WEBVTT

    1
    00:00.000 --> 00:02.000
    <v.first.loud Esme>It’s a blue apple tree!

    2
    00:02.000 --> 00:04.000
    <v	Mary>No way!

    3
    00:04.000 --> 00:06.000
    <v Esme F>Hee!

    4
    00:06.000 --> 00:08.000
    <v.loud Mary>That’s awesome!
    """

    %Vtt{headers: [], cues: cues} = Vttyl.parse(vtt)
    assert Enum.count(cues) == 4

    assert cues == [
             %Vttyl.Part{
               start: 0,
               end: 2000,
               text: "It’s a blue apple tree!",
               part: 1,
               voice: "Esme",
               settings: []
             },
             %Vttyl.Part{
               start: 2000,
               end: 4000,
               text: "No way!",
               part: 2,
               voice: "Mary",
               settings: []
             },
             %Vttyl.Part{
               start: 4000,
               end: 6000,
               text: "Hee!",
               part: 3,
               voice: "Esme F",
               settings: []
             },
             %Vttyl.Part{
               start: 6000,
               end: 8000,
               text: "That’s awesome!",
               part: 4,
               voice: "Mary",
               settings: []
             }
           ]
  end

  @tag :skip
  test "encodes voice" do
    encoded =
      %Vttyl.Vtt{
        use_cue_identifiers: true,
        headers: [],
        cues: [
          %Vttyl.Part{
            start: 0,
            end: 2000,
            text: "It’s a blue apple tree!",
            part: 1,
            voice: "Esme",
            settings: []
          },
          %Vttyl.Part{
            start: 2000,
            end: 4000,
            text: "No way!",
            part: 2,
            voice: "Mary",
            settings: []
          },
          %Vttyl.Part{
            start: 4000,
            end: 6000,
            text: "Hee!",
            part: 3,
            voice: "Esme F",
            settings: []
          },
          %Vttyl.Part{
            start: 6000,
            end: 8000,
            text: "That’s awesome!",
            part: 4,
            voice: "Mary",
            settings: []
          }
        ]
      }
      |> Vttyl.encode()

    expected = """
    WEBVTT

    1
    00:00.000 --> 00:02.000
    <v.first.loud Esme>It’s a blue apple tree!

    2
    00:02.000 --> 00:04.000
    <v	Mary>No way!

    3
    00:04.000 --> 00:06.000
    <v Esme F>Hee!

    4
    00:06.000 --> 00:08.000
    <v.loud Mary>That’s awesome!
    """

    assert encoded == expected
  end

  test "parses multiple lines" do
    vtt = """
    WEBVTT

    1
    00:00:04.047 --> 00:00:09.135
    first

    2
    00:00:10.010 --> 00:00:10.638
    line 1
    line 2

    3
    00:00:12.722 --> 00:00:13.473
    line 2.1
    line 2.2
    line 2.3
    """

    %Vtt{headers: [], cues: cues} = Vttyl.parse(vtt)
    assert Enum.count(cues) == 3
    assert Enum.at(cues, 0) |> Map.get(:text) == "first"
    assert Enum.at(cues, 1) |> Map.get(:text) == "line 1\nline 2"
    assert Enum.at(cues, 2) |> Map.get(:text) == "line 2.1\nline 2.2\nline 2.3"
  end

  test "encoded multiple lines" do
    encoded =
      %Vttyl.Vtt{
        use_cue_identifiers: true,
        headers: [],
        cues: [
          %Vttyl.Part{
            start: 4047,
            end: 9135,
            text: "first",
            part: 1,
            voice: nil,
            settings: []
          },
          %Vttyl.Part{
            start: 10010,
            end: 10638,
            text: "line 1\nline 2",
            part: 2,
            voice: nil,
            settings: []
          },
          %Vttyl.Part{
            start: 12722,
            end: 13473,
            text: "line 2.1\nline 2.2\nline 2.3",
            part: 3,
            voice: nil,
            settings: []
          }
        ]
      }
      |> Vttyl.encode()

    expected = """
    WEBVTT

    1
    00:00:04.047 --> 00:00:09.135
    first

    2
    00:00:10.010 --> 00:00:10.638
    line 1
    line 2

    3
    00:00:12.722 --> 00:00:13.473
    line 2.1
    line 2.2
    line 2.3
    """

    assert encoded == expected
  end

  #   @expected_result [
  #     %Part{
  #       end: 17609,
  #       part: 1,
  #       start: 15450,
  #       text: "Hello"
  #     },
  #     %Part{
  #       end: 21240,
  #       part: 2,
  #       start: 20700,
  #       text: "Hi"
  #     },
  #     %Part{
  #       end: 64470,
  #       part: 3,
  #       start: 53970,
  #       text: "My name is Andy."
  #     },
  #     %Part{
  #       end: 76380,
  #       part: 4,
  #       start: 68040,
  #       text: "What a coincidence! Mine is too."
  #     }
  #   ]
  #
  #   def get_vtt_file(file_name) do
  #     :vttyl
  #     |> :code.priv_dir()
  #     |> Path.join(["samples", "/#{file_name}"])
  #   end
  #
  #   describe "encode_vtt/1" do
  #     setup tags do
  #       part = %Part{
  #         part: Map.get(tags, :part, 1),
  #         start: Map.get(tags, :start, 1000),
  #         end: Map.get(tags, :end, 10_000),
  #         text: Map.get(tags, :text, "Hello world")
  #       }
  #
  #       {:ok, %{parts: [part]}}
  #     end
  #
  #     def make_vtt(part, start_ts, end_ts, text) do
  #       "WEBVTT\n\n#{part}\n#{start_ts} --> #{end_ts}\n#{text}\n"
  #     end
  #
  #     test "basic", %{parts: parts} do
  #       assert make_vtt(1, "00:01.000", "00:10.000", "Hello world") == Vttyl.encode_vtt(parts)
  #     end
  #
  #     @tag start: 100_000_000
  #     @tag end: 100_100_001
  #     test "large numbers", %{parts: parts} do
  #       assert make_vtt(1, "27:46:40.000", "27:48:20.001", "Hello world") == Vttyl.encode_vtt(parts)
  #     end
  #
  #     test "encodes settings" do
  #       parts = [
  #         %Part{
  #           part: 1,
  #           start: 1000,
  #           end: 10_000,
  #           text: "Hello world",
  #           settings: [{"align", "center"}]
  #         }
  #       ]
  #
  #       assert Vttyl.encode_vtt(parts) ==
  #                "WEBVTT\n\n1\n00:01.000 --> 00:10.000 align:center\nHello world\n"
  #     end
  #
  #     test "encodes multiple settings" do
  #       parts = [
  #         %Part{
  #           part: 1,
  #           start: 1000,
  #           end: 10_000,
  #           text: "Hello world",
  #           settings: [{"align", "center"}, {"line", "85%"}, {"position", "50%"}, {"size", "40%"}]
  #         }
  #       ]
  #
  #       assert Vttyl.encode_vtt(parts) ==
  #                "WEBVTT\n\n1\n00:01.000 --> 00:10.000 align:center line:85% position:50% size:40%\nHello world\n"
  #     end
  #
  #     test "encodes headers" do
  #       parts = [
  #         %Vttyl.Header{
  #           values: [{"X-TIMESTAMP-MAP=LOCAL", "00:00:00.000"}, {"MPEGTS", "900000"}]
  #         },
  #         %Vttyl.Part{
  #           start: 15450,
  #           end: 17609,
  #           text: "Hello",
  #           part: 1,
  #           voice: nil,
  #           settings: []
  #         },
  #         %Vttyl.Part{
  #           start: 20700,
  #           end: 21240,
  #           text: "Hi",
  #           part: 2,
  #           voice: nil,
  #           settings: []
  #         },
  #         %Vttyl.Part{
  #           start: 53970,
  #           end: 64470,
  #           text: "My name is Andy.",
  #           part: 3,
  #           voice: nil,
  #           settings: []
  #         },
  #         %Vttyl.Part{
  #           start: 68040,
  #           end: 76380,
  #           text: "What a coincidence! Mine is too.",
  #           part: 4,
  #           voice: nil,
  #           settings: []
  #         }
  #       ]
  #
  #       encoded = Vttyl.encode_vtt(parts)
  #       String.contains?(encoded, "WEBVTT\nX-TIMESTAMP-MAP=LOCAL:00:00:00.000,MPEGTS:900000")
  #     end
  #   end
  #
  #   describe "encode_srt/1" do
  #     setup tags do
  #       part = %Part{
  #         part: Map.get(tags, :part, 1),
  #         start: Map.get(tags, :start, 1000),
  #         end: Map.get(tags, :end, 10_000),
  #         text: Map.get(tags, :text, "Hello world")
  #       }
  #
  #       {:ok, %{parts: [part]}}
  #     end
  #
  #     def make_srt(part, start_ts, end_ts, text) do
  #       "#{part}\n#{start_ts} --> #{end_ts}\n#{text}\n"
  #     end
  #
  #     test "basic", %{parts: parts} do
  #       assert make_srt(1, "00:00:01,000", "00:00:10,000", "Hello world") == Vttyl.encode_srt(parts)
  #     end
  #
  #     test "multi line" do
  #       parts = [
  #         %Part{
  #           part: 1,
  #           start: 1000,
  #           end: 10_000,
  #           text: "Hello"
  #         },
  #         %Part{
  #           part: 2,
  #           start: 2000,
  #           end: 20_000,
  #           text: "world"
  #         }
  #       ]
  #
  #       expect =
  #         make_srt(1, "00:00:01,000", "00:00:10,000", "Hello") <>
  #           "\n" <> make_srt(2, "00:00:02,000", "00:00:20,000", "world")
  #
  #       assert expect == Vttyl.encode_srt(parts)
  #     end
  #
  #     @tag start: 100_000_000
  #     @tag end: 100_100_001
  #     test "large numbers", %{parts: parts} do
  #       assert make_srt(1, "27:46:40,000", "27:48:20,001", "Hello world") == Vttyl.encode_srt(parts)
  #     end
  #   end
end
