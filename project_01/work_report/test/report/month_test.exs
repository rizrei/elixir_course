defmodule WorkReport.Report.MonthTest do
  use ExUnit.Case, async: true

  alias WorkReport.Report.{Month, Day, Task}

  describe "new/1" do
    test "creates a new month with valid English month name" do
      months = [
        "January",
        "February",
        "March",
        "April",
        "May",
        "June",
        "July",
        "August",
        "September",
        "October",
        "November",
        "December"
      ]

      Enum.each(months, fn month_name ->
        month = Month.new(month_name)
        assert month.name == month_name
        assert month.days == []
      end)
    end

    test "assigns correct number to each month" do
      assert Month.new("January").number == 1
      assert Month.new("December").number == 12
      assert Month.new("June").number == 6
    end
  end

  describe "add_day/2" do
    test "adds a day to an empty month" do
      month = Month.new("January")
      day = %Day{number: 1, name: "Monday"}

      result = Month.add_day(month, day)

      assert result.days == [day]
    end

    test "adds multiple days to a month" do
      month = Month.new("February")
      day1 = %Day{number: 1, name: "Monday"}
      day2 = %Day{number: 2, name: "Tuesday"}
      day3 = %Day{number: 3, name: "Wednesday"}

      result =
        month
        |> Month.add_day(day1)
        |> Month.add_day(day2)
        |> Month.add_day(day3)

      assert ^result = %Month{
               name: "February",
               number: 2,
               days: [day3, day2, day1]
             }
    end
  end

  describe "days_count/1" do
    test "returns 0 for a month with no days" do
      assert Month.new("May") |> Month.days_count() == 0
    end

    test "counts a single day" do
      day = %Day{number: 1, name: "Monday"}

      result = Month.new("June") |> Month.add_day(day) |> Month.days_count()

      assert result == 1
    end

    test "counts multiple days" do
      day1 = %Day{number: 1, name: "Monday"}
      day2 = %Day{number: 2, name: "Tuesday"}
      day3 = %Day{number: 3, name: "Wednesday"}

      result =
        Month.new("July")
        |> Month.add_day(day1)
        |> Month.add_day(day2)
        |> Month.add_day(day3)
        |> Month.days_count()

      assert result == 3
    end
  end

  describe "total_minutes/1" do
    test "returns 0 for a month with no days" do
      month = Month.new("August")
      assert Month.total_minutes(month) == 0
    end

    test "calculates total minutes from a single day" do
      month = Month.new("September")
      task1 = %Task{category: "DEV", description: "Fix bug", minutes: 60}
      task2 = %Task{category: "DOC", description: "Write docs", minutes: 30}

      day = %Day{number: 1, name: "Monday", tasks: [task1, task2]}
      result = Month.add_day(month, day)

      assert Month.total_minutes(result) == 90
    end

    test "calculates total minutes from multiple days" do
      month = Month.new("October")
      task1 = %Task{category: "DEV", description: "Fix bug", minutes: 60}
      task2 = %Task{category: "DOC", description: "Write docs", minutes: 30}
      task3 = %Task{category: "COMM", description: "Meeting", minutes: 45}

      day1 = %Day{number: 1, name: "Monday", tasks: [task1, task2]}
      day2 = %Day{number: 2, name: "Tuesday", tasks: [task3]}

      result =
        month
        |> Month.add_day(day1)
        |> Month.add_day(day2)

      assert Month.total_minutes(result) == 135
    end

    test "handles days with no tasks" do
      month = Month.new("November")
      task1 = %Task{category: "DEV", description: "Code", minutes: 120}
      day1 = %Day{number: 1, name: "Monday", tasks: [task1]}
      day2 = %Day{number: 2, name: "Tuesday", tasks: []}

      result =
        month
        |> Month.add_day(day1)
        |> Month.add_day(day2)

      assert Month.total_minutes(result) == 120
    end
  end

  describe "minutes_by_category/1" do
    test "returns empty map for a month with no days" do
      month = Month.new("December")
      result = Month.minutes_by_category(month)
      assert result == %{}
    end

    test "calculates minutes by category from a single day" do
      month = Month.new("January")
      task1 = %Task{category: "DEV", description: "Fix", minutes: 60}
      task2 = %Task{category: "DEV", description: "Feature", minutes: 90}
      task3 = %Task{category: "DOC", description: "Docs", minutes: 30}

      day = %Day{number: 1, name: "Monday", tasks: [task1, task2, task3]}
      result = month |> Month.add_day(day) |> Month.minutes_by_category()

      assert result == %{"DEV" => 150, "DOC" => 30}
    end

    test "aggregates minutes by category from multiple days" do
      month = Month.new("February")
      task1 = %Task{category: "DEV", description: "Fix", minutes: 60}
      task2 = %Task{category: "DOC", description: "Docs", minutes: 30}
      task3 = %Task{category: "DEV", description: "Feature", minutes: 40}
      task4 = %Task{category: "COMM", description: "Meeting", minutes: 50}

      day1 = %Day{number: 1, name: "Monday", tasks: [task1, task2]}
      day2 = %Day{number: 2, name: "Tuesday", tasks: [task3, task4]}

      result =
        month
        |> Month.add_day(day1)
        |> Month.add_day(day2)
        |> Month.minutes_by_category()

      assert result == %{"DEV" => 100, "DOC" => 30, "COMM" => 50}
    end

    test "handles multiple categories across multiple days" do
      month = Month.new("March")
      task1 = %Task{category: "EDU", description: "Learn", minutes: 20}
      task2 = %Task{category: "OPS", description: "Deploy", minutes: 15}
      task3 = %Task{category: "EDU", description: "Practice", minutes: 40}
      task4 = %Task{category: "OPS", description: "Monitor", minutes: 10}
      task5 = %Task{category: "WS", description: "Workshop", minutes: 120}

      day1 = %Day{number: 1, name: "Monday", tasks: [task1, task2]}
      day2 = %Day{number: 2, name: "Tuesday", tasks: [task3, task4]}
      day3 = %Day{number: 3, name: "Wednesday", tasks: [task5]}

      result =
        month
        |> Month.add_day(day1)
        |> Month.add_day(day2)
        |> Month.add_day(day3)
        |> Month.minutes_by_category()

      assert result == %{"EDU" => 60, "OPS" => 25, "WS" => 120}
    end
  end

  describe "stats/1" do
    test "returns correct stats for a single day" do
      month = Month.new("August")
      task1 = %Task{category: "DEV", description: "Fix", minutes: 60}
      task2 = %Task{category: "DOC", description: "Docs", minutes: 30}

      day = %Day{number: 1, name: "Monday", tasks: [task1, task2]}

      result =
        month
        |> Month.add_day(day)
        |> Month.stats()

      assert result.total_minutes == 90
      assert result.days_count == 1
      assert result.minutes_by_category == %{"DEV" => 60, "DOC" => 30}
    end

    test "returns correct stats for multiple days" do
      month = Month.new("September")
      task1 = %Task{category: "DEV", description: "Fix", minutes: 60}
      task2 = %Task{category: "DOC", description: "Docs", minutes: 30}
      task3 = %Task{category: "DEV", description: "Feature", minutes: 90}

      day1 = %Day{number: 1, name: "Monday", tasks: [task1, task2]}
      day2 = %Day{number: 2, name: "Tuesday", tasks: [task3]}

      result =
        month
        |> Month.add_day(day1)
        |> Month.add_day(day2)
        |> Month.stats()

      assert result.total_minutes == 180
      assert result.days_count == 2
      assert result.minutes_by_category == %{"DEV" => 150, "DOC" => 30}
    end

    test "calculates average minutes per day correctly" do
      month = Month.new("October")
      task1 = %Task{category: "DEV", description: "Fix", minutes: 100}
      task2 = %Task{category: "DOC", description: "Docs", minutes: 50}
      task3 = %Task{category: "COMM", description: "Meeting", minutes: 100}

      day1 = %Day{number: 1, name: "Monday", tasks: [task1]}
      day2 = %Day{number: 2, name: "Tuesday", tasks: [task2, task3]}

      result =
        month
        |> Month.add_day(day1)
        |> Month.add_day(day2)
        |> Month.stats()

      assert result.total_minutes == 250
      assert result.days_count == 2
      assert result.avg_minutes_by_day == 125.0
    end

    test "handles average calculation with days without tasks" do
      month = Month.new("November")
      task1 = %Task{category: "DEV", description: "Code", minutes: 120}
      day1 = %Day{number: 1, name: "Monday", tasks: [task1]}
      day2 = %Day{number: 2, name: "Tuesday", tasks: []}

      result =
        month
        |> Month.add_day(day1)
        |> Month.add_day(day2)
        |> Month.stats()

      assert result.total_minutes == 120
      assert result.days_count == 2
      assert result.avg_minutes_by_day == 60.0
    end

    test "returns stats with all expected keys" do
      month = Month.new("December")
      task = %Task{category: "EDU", description: "Learn", minutes: 90}
      day = %Day{number: 1, name: "Monday", tasks: [task]}

      result =
        month
        |> Month.add_day(day)
        |> Month.stats()

      assert Map.has_key?(result, :total_minutes)
      assert Map.has_key?(result, :days_count)
      assert Map.has_key?(result, :avg_minutes_by_day)
      assert Map.has_key?(result, :minutes_by_category)
    end

    test "handles empty month" do
      month = Month.new("January")

      assert Month.stats(month) == %{
               total_minutes: 0,
               days_count: 0,
               avg_minutes_by_day: 0,
               minutes_by_category: %{}
             }
    end
  end
end
