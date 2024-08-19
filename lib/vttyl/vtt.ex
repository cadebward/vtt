defmodule Vttyl.Vtt do
  @type t :: %__MODULE__{
          use_cue_identifiers: boolean(),
          headers: [Vttyl.Header.t()],
          cues: [Vttyl.Part.t()]
        }
  defstruct use_cue_identifiers: true, headers: [], cues: []
end
