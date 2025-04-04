defmodule Tablature do
  def parse(tab) do
    tab
    |> String.split("\n", trim: true)
    |> Enum.with_index()
    |> Enum.flat_map(fn {line, line_index} ->
      case String.split(line, "|") do
        [header, content | _] ->
          string_letter = String.trim(header)

          Regex.scan(~r/\d+/, content, return: :index)
          |> Enum.map(fn [{start, length} | _] ->
            note = string_letter <> String.slice(content, start, length)
            {start, line_index, note}
          end)

        _ ->
          []
      end
    end)
    |> Enum.group_by(fn {start, _line_index, _note} -> start end)
    |> Enum.sort_by(fn {start, _notes} -> start end)
    |> Enum.map(fn {_start, notes} ->
         notes
         |> Enum.sort_by(fn {_pos, line_index, _note} -> line_index end)
         |> Enum.map(fn {_pos, _line, note} -> note end)
         |> Enum.join("/")
    end)
    |> Enum.join(" ")
  end
end
