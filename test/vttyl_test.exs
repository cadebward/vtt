defmodule VttTest do
  @moduledoc false

  use ExUnit.Case, async: true

  doctest Vtt

  alias Vtt.Cue
  alias Vtt.Header

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

    %Vtt{headers: [], cues: cues} = Vtt.parse(vtt)
    assert Enum.count(cues) == 3

    assert cues == [
             %Cue{
               start: 4047,
               end: 9135,
               text: "line 1",
               part: 1,
               voice: nil,
               settings: []
             },
             %Cue{
               start: 10010,
               end: 10638,
               text: "line 2",
               part: 2,
               voice: nil,
               settings: []
             },
             %Cue{
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
          %Cue{
            start: 4047,
            end: 9135,
            text: "line 1",
            part: 1,
            voice: nil,
            settings: []
          },
          %Cue{
            start: 10010,
            end: 10638,
            text: "line 2",
            part: 2,
            voice: nil,
            settings: []
          },
          %Cue{
            start: 12722,
            end: 13473,
            text: "line 3",
            part: 3,
            voice: nil,
            settings: []
          }
        ]
      }
      |> Vtt.encode()

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

    %Vtt{headers: headers, cues: cues} = Vtt.parse(vtt)
    assert Enum.count(cues) == 3
    assert Enum.count(headers) == 1

    assert Enum.at(headers, 0) == %Header{
             values: [{"X-TIMESTAMP-MAP=LOCAL", "00:00:00.000"}, {"MPEGTS", "900000"}]
           }
  end

  test "encodes vtt with headers" do
    encoded =
      %Vtt{
        headers: [
          %Vtt.Header{
            values: [{"X-TIMESTAMP-MAP=LOCAL", "00:00:00.000"}, {"MPEGTS", "900000"}]
          }
        ],
        cues: [
          %Cue{
            start: 4047,
            end: 9135,
            text: "line 1",
            part: 1,
            voice: nil,
            settings: []
          },
          %Cue{
            start: 10010,
            end: 10638,
            text: "line 2",
            part: 2,
            voice: nil,
            settings: []
          },
          %Cue{
            start: 12722,
            end: 13473,
            text: "line 3",
            part: 3,
            voice: nil,
            settings: []
          }
        ]
      }
      |> Vtt.encode()

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

    %Vtt{headers: [], cues: cues, use_cue_identifiers: false} = Vtt.parse(vtt)
    assert Enum.count(cues) == 3

    assert cues == [
             %Cue{
               start: 4047,
               end: 9135,
               text: "line 1",
               part: 0,
               voice: nil,
               settings: []
             },
             %Cue{
               start: 10010,
               end: 10638,
               text: "line 2",
               part: 0,
               voice: nil,
               settings: []
             },
             %Cue{
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
      %Vtt{
        use_cue_identifiers: false,
        headers: [],
        cues: [
          %Cue{
            start: 4047,
            end: 9135,
            text: "line 1",
            part: 0,
            voice: nil,
            settings: []
          },
          %Cue{
            start: 10010,
            end: 10638,
            text: "line 2",
            part: 0,
            voice: nil,
            settings: []
          },
          %Cue{
            start: 12722,
            end: 13473,
            text: "line 3",
            part: 0,
            voice: nil,
            settings: []
          }
        ]
      }
      |> Vtt.encode()

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

    %Vtt{headers: [], cues: cues} = Vtt.parse(vtt)

    assert Enum.count(cues) == 3

    assert cues == [
             %Cue{
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
             %Cue{
               start: 10010,
               end: 10638,
               text: "line 2",
               part: 0,
               voice: nil,
               settings: [{"align", "center"}]
             },
             %Cue{
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
      %Vtt{
        use_cue_identifiers: false,
        headers: [],
        cues: [
          %Cue{
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
          %Cue{
            start: 10010,
            end: 10638,
            text: "line 2",
            part: 0,
            voice: nil,
            settings: [{"align", "center"}]
          },
          %Cue{
            start: 12722,
            end: 13473,
            text: "line 3",
            part: 0,
            voice: nil,
            settings: []
          }
        ]
      }
      |> Vtt.encode()

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

    %Vtt{headers: [], cues: cues} = Vtt.parse(vtt)
    assert Enum.count(cues) == 4

    assert cues == [
             %Cue{
               start: 0,
               end: 2000,
               text: "It’s a blue apple tree!",
               part: 1,
               voice: "Esme",
               settings: []
             },
             %Cue{
               start: 2000,
               end: 4000,
               text: "No way!",
               part: 2,
               voice: "Mary",
               settings: []
             },
             %Cue{
               start: 4000,
               end: 6000,
               text: "Hee!",
               part: 3,
               voice: "Esme F",
               settings: []
             },
             %Cue{
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
      %Vtt{
        use_cue_identifiers: true,
        headers: [],
        cues: [
          %Cue{
            start: 0,
            end: 2000,
            text: "It’s a blue apple tree!",
            part: 1,
            voice: "Esme",
            settings: []
          },
          %Cue{
            start: 2000,
            end: 4000,
            text: "No way!",
            part: 2,
            voice: "Mary",
            settings: []
          },
          %Cue{
            start: 4000,
            end: 6000,
            text: "Hee!",
            part: 3,
            voice: "Esme F",
            settings: []
          },
          %Cue{
            start: 6000,
            end: 8000,
            text: "That’s awesome!",
            part: 4,
            voice: "Mary",
            settings: []
          }
        ]
      }
      |> Vtt.encode()

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

    %Vtt{headers: [], cues: cues} = Vtt.parse(vtt)
    assert Enum.count(cues) == 3
    assert Enum.at(cues, 0) |> Map.get(:text) == "first"
    assert Enum.at(cues, 1) |> Map.get(:text) == "line 1\nline 2"
    assert Enum.at(cues, 2) |> Map.get(:text) == "line 2.1\nline 2.2\nline 2.3"
  end

  test "encoded multiple lines" do
    encoded =
      %Vtt{
        use_cue_identifiers: true,
        headers: [],
        cues: [
          %Cue{
            start: 4047,
            end: 9135,
            text: "first",
            part: 1,
            voice: nil,
            settings: []
          },
          %Cue{
            start: 10010,
            end: 10638,
            text: "line 1\nline 2",
            part: 2,
            voice: nil,
            settings: []
          },
          %Cue{
            start: 12722,
            end: 13473,
            text: "line 2.1\nline 2.2\nline 2.3",
            part: 3,
            voice: nil,
            settings: []
          }
        ]
      }
      |> Vtt.encode()

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
end
