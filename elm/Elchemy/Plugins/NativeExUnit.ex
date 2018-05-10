defmodule Elchemy.Plugins.NativeExUnit do
  alias Elchemy.Plugins.NativeAst

  def define_tests(tests) do
    {%{
       name: suite_name,
       initial_value: initial_value,
       setup_all: {:setup, setup_all_f},
       setup: {:setup, setup_f},
       tests: tests
     }, []} = Code.eval_quoted(tests)

    inner =
      for {:test, name, f} <- tests do
        body = f |> IO.inspect()

        quote do
          test unquote(name), %{context: context} do
            assert unquote(body).(context)
          end
        end
      end

    tests_def =
      quote do
        setup_all do
          %{context: unquote(setup_all_f).(unquote(initial_value))}
        end

        describe unquote(suite_name) do
          setup %{context: context} do
            %{context: unquote(setup_f).(context)}
          end

          unquote(inner)
        end
      end
      |> Macro.escape()

    quote do
      def tests() do
        unquote(tests_def)
      end
    end
  end
end
