defmodule WorkReport.Report.DayTest do
  use ExUnit.Case

  alias WorkReport.Report.Day
  alias WorkReport.Report.Task

  describe "add_task/2" do
    test "adds a task to an empty day" do
      day = %Day{number: 1, name: "Monday"}
      task = %Task{category: "DEV", description: "Fix bug", minutes: 60}

      result = Day.add_task(day, task)

      assert result.next_task_position == 2
      assert length(result.tasks) == 1
      assert hd(result.tasks).position == 1
    end

    test "adds multiple tasks with incrementing positions" do
      day = %Day{number: 1, name: "Monday"}
      task1 = %Task{category: "DEV", description: "Fix bug", minutes: 60}
      task2 = %Task{category: "DOC", description: "Write docs", minutes: 30}
      task3 = %Task{category: "COMM", description: "Meeting", minutes: 45}

      result =
        day
        |> Day.add_task(task1)
        |> Day.add_task(task2)
        |> Day.add_task(task3)

      assert result.next_task_position == 4
      assert length(result.tasks) == 3

      # Tasks are added to the front of the list, so they're in reverse order
      [third_task, second_task, first_task] = result.tasks
      assert first_task.position == 1
      assert second_task.position == 2
      assert third_task.position == 3
    end

    test "updates next_task_position correctly" do
      day = %Day{number: 1, name: "Monday"}
      task = %Task{category: "DEV", description: "Code", minutes: 120}

      result = Day.add_task(day, task)

      assert result.next_task_position == 2

      result = Day.add_task(result, task)
      assert result.next_task_position == 3
    end

    test "preserves task data except position" do
      day = %Day{number: 2, name: "Tuesday"}
      task = %Task{category: "EDU", description: "Learn Elixir", minutes: 90}

      result = Day.add_task(day, task)

      added_task = hd(result.tasks)
      assert added_task.category == "EDU"
      assert added_task.description == "Learn Elixir"
      assert added_task.minutes == 90
      assert added_task.position == 1
    end
  end

  describe "total_minutes/1" do
    test "returns 0 for a day with no tasks" do
      day = %Day{number: 1, name: "Monday", tasks: []}

      assert Day.total_minutes(day) == 0
    end

    test "calculates total minutes from a single task" do
      task = %Task{category: "DEV", description: "Fix bug", minutes: 60}
      day = %Day{number: 1, name: "Monday", tasks: [task]}

      assert Day.total_minutes(day) == 60
    end

    test "calculates total minutes from multiple tasks" do
      task1 = %Task{category: "DEV", description: "Fix bug", minutes: 60}
      task2 = %Task{category: "DOC", description: "Write docs", minutes: 30}
      task3 = %Task{category: "COMM", description: "Meeting", minutes: 45}

      day = %Day{number: 1, name: "Monday", tasks: [task1, task2, task3]}

      assert Day.total_minutes(day) == 135
    end

    test "calculates total minutes for a day built with add_task" do
      day = %Day{number: 1, name: "Monday"}
      task1 = %Task{category: "DEV", description: "Fix bug", minutes: 60}
      task2 = %Task{category: "DOC", description: "Write docs", minutes: 30}

      result =
        day
        |> Day.add_task(task1)
        |> Day.add_task(task2)

      assert Day.total_minutes(result) == 90
    end

    test "handles tasks with 0 minutes" do
      task1 = %Task{category: "DEV", description: "Task 1", minutes: 0}
      task2 = %Task{category: "DOC", description: "Task 2", minutes: 30}

      day = %Day{number: 1, name: "Monday", tasks: [task1, task2]}

      assert Day.total_minutes(day) == 30
    end
  end

  describe "minutes_by_category/1" do
    test "returns empty map for a day with no tasks" do
      day = %Day{number: 1, name: "Monday", tasks: []}

      result = Day.minutes_by_category(day)

      assert result == %{}
    end

    test "calculates minutes for a single category" do
      task1 = %Task{category: "DEV", description: "Fix bug", minutes: 60}
      task2 = %Task{category: "DEV", description: "New feature", minutes: 90}

      day = %Day{number: 1, name: "Monday", tasks: [task1, task2]}

      result = Day.minutes_by_category(day)

      assert result == %{"DEV" => 150}
    end

    test "calculates minutes for multiple categories" do
      task1 = %Task{category: "DEV", description: "Fix bug", minutes: 60}
      task2 = %Task{category: "DOC", description: "Write docs", minutes: 30}
      task3 = %Task{category: "COMM", description: "Meeting", minutes: 45}
      task4 = %Task{category: "DEV", description: "New feature", minutes: 90}

      day = %Day{number: 1, name: "Monday", tasks: [task1, task2, task3, task4]}

      result = Day.minutes_by_category(day)

      assert result == %{"DEV" => 150, "DOC" => 30, "COMM" => 45}
    end

    test "aggregates minutes correctly for repeated categories" do
      task1 = %Task{category: "EDU", description: "Learn", minutes: 20}
      task2 = %Task{category: "OPS", description: "Deploy", minutes: 15}
      task3 = %Task{category: "EDU", description: "Practice", minutes: 40}
      task4 = %Task{category: "OPS", description: "Monitor", minutes: 10}

      day = %Day{number: 1, name: "Monday", tasks: [task1, task2, task3, task4]}

      result = Day.minutes_by_category(day)

      assert result == %{"EDU" => 60, "OPS" => 25}
    end

    test "handles tasks with 0 minutes" do
      task1 = %Task{category: "DEV", description: "Task", minutes: 0}
      task2 = %Task{category: "DEV", description: "Another", minutes: 30}

      day = %Day{number: 1, name: "Monday", tasks: [task1, task2]}

      result = Day.minutes_by_category(day)

      assert result == %{"DEV" => 30}
    end

    test "calculates minutes for a day built with add_task" do
      day = %Day{number: 1, name: "Monday"}
      task1 = %Task{category: "DEV", description: "Fix bug", minutes: 60}
      task2 = %Task{category: "DOC", description: "Write docs", minutes: 30}
      task3 = %Task{category: "DEV", description: "Feature", minutes: 90}

      result =
        day
        |> Day.add_task(task1)
        |> Day.add_task(task2)
        |> Day.add_task(task3)
        |> Day.minutes_by_category()

      assert result == %{"DEV" => 150, "DOC" => 30}
    end
  end
end
