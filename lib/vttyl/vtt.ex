defmodule Vtt.Vtt do
  @type t :: %__MODULE__{
          use_cue_identifiers: boolean(),
          headers: [Vtt.Header.t()],
          cues: [Vtt.Part.t()]
        }
  defstruct use_cue_identifiers: true, headers: [], cues: []
end
