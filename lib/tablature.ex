defmodule Tablature do


  @num_strings 6
  def parse(tab) do
    lines =
      tab
      |> String.split("\n", trim: true)
      |> Enum.reject(&(&1 == ""))

    segments = Enum.chunk_every(lines, @num_strings)

    string_content_map =
      Enum.reduce(segments, %{}, fn segment_lines, acc_map ->
        Enum.with_index(segment_lines)
        |> Enum.reduce(acc_map, fn {line, line_index}, inner_acc_map ->
          case String.split(line, "|", parts: 2) do
            [header, content] ->
              string_name = String.trim(header)
              Map.update(
                inner_acc_map,
                {line_index, string_name},
                [String.trim_trailing(content)],
                &([String.trim_trailing(content) | &1])
              )
            _ ->
              inner_acc_map
          end
        end)
      end)

    string_data =
      string_content_map
      |> Enum.map(fn {{line_index, string_name}, content_list} ->
           full_content = Enum.reverse(content_list) |> Enum.join()
           {line_index, string_name, full_content}
         end)
      |> Enum.sort_by(fn {line_index, _, _} -> line_index end)

    content_length =
      case string_data do
        [{_, _, first_content} | _] -> String.length(first_content)
        [] -> 0
      end

    final_notes =
      Enum.map(0..(content_length - 1), fn col_index ->
        notes_in_column =
          Enum.reduce(string_data, [], fn {line_index, string_name, full_content}, acc_notes ->
            if col_index < String.length(full_content) do
              char = String.at(full_content, col_index)
              if !is_nil(char) and String.match?(char, ~r/\d/) do
                 note = string_name <> char
                 [{line_index, note} | acc_notes]
              else
                acc_notes
              end
            else
              acc_notes
            end
          end)

        chars_in_column =
          Enum.map(string_data, fn {_, _, full_content} ->
             if col_index < String.length(full_content) do
               String.at(full_content, col_index)
             else
               nil
             end
          end)

        cond do
          notes_in_column != [] ->
            notes_in_column
            |> Enum.sort_by(fn {line_idx, _note} -> line_idx end)
            |> Enum.map(fn {_line_idx, note} -> note end)
            |> Enum.join("/")
          Enum.all?(chars_in_column, &(&1 == "-")) ->
             "_"
          true ->
             nil
        end
      end)
      |> Enum.reject(&is_nil(&1))

    Enum.join(final_notes, " ")
  end
end
