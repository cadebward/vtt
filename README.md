# Vtt

> A dead simple vtt parser in Elixir.

## Installation

To install Vtt, add it to your `mix.exs` file.

```elixir
def deps do
  [
    {:vtt, "~> 0.1.0"}
  ]
end
```

Then, run `$ mix deps.get`.

## Usage

### Decoding

Vtt has two basic ways to use it.

#### String Parsing

```elixir
iex> vtt = """
           WEBVTT

           1
           00:00:15.450 --> 00:00:17.609
           Hello world!
           """
...> Vtt.parse(vtt)
%Vtt{cues: [%Vtt.Cue{end: 17609, part: 1, start: 15450, text: "Hello world!", voice: nil}]}
```

#### Simple Voice Spans

(Closing voice spans are currently not supported)

```elixir
iex> vtt = """
           WEBVTT

           1
           00:00:15.450 --> 00:00:17.609
           <v Andy>Hello world!
           """
...> Vtt.parse(vtt)
%Vtt{cues: [%Vtt.Cue{end: 17609, part: 1, start: 15450, text: "Hello world!", voice: "Andy"}]}
```


### Encoding

Vtt also supports encoding parts.

```elixir
iex> vtt = %Vtt{cues: [%Vtt.Cue{end: 17609, part: 1, start: 15450, text: "Hello world!"}]}
...> Vtt.encode(vtt)
"""
WEBVTT
1
00:00:15.450 --> 00:00:17.609
Hello world!
"""
```

```elixir
iex> vtt = %Vtt{cues: [%Vtt.Cue{end: 17609, part: 1, start: 15450, text: "Hello world!", voice: "Andy"}]}
...> Vtt.encode(vtt)
"""
WEBVTT
1
00:00:15.450 --> 00:00:17.609
<v Andy>Hello world!
"""
```

