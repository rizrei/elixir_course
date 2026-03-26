defmodule WorkReport.Report.MonthTest do
  @moduledoc false

  use ExUnit.Case, async: true

  alias WorkReport.Report.{Month, Day, Task}

  def create_month(name) do
    {:ok, month} = Month.new(name)
    month
  end

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
        assert {:ok, %Month{name: ^month_name, days: []}} = Month.new(month_name)
      end)
    end

    test "assigns correct number to each month" do
      assert {:ok, %Month{name: "January", number: 1}} = Month.new("January")
      assert {:ok, %Month{name: "December", number: 12}} = Month.new("December")
      assert {:ok, %Month{name: "June", number: 6}} = Month.new("June")
    end

    test "returns error for invalid month name" do
      assert {:error, "Invalid month name: Foo"} = Month.new("Foo")
      assert {:error, "Invalid month name: Jan"} = Month.new("Jan")
      assert {:error, "Invalid month name: 123"} = Month.new("123")
    end
  end

  describe "add_day/2" do
    test "adds a day to an empty month" do
      day = %Day{number: 1, name: "Monday"}

      assert %Month{days: [^day]} = create_month("January") |> Month.add_day(day)
    end

    test "adds multiple days to a month" do
      day1 = %Day{number: 1, name: "Monday"}
      day2 = %Day{number: 2, name: "Tuesday"}
      day3 = %Day{number: 3, name: "Wednesday"}

      result =
        create_month("February")
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
      assert create_month("May") |> Month.days_count() == 0
    end

    test "counts a single day" do
      result =
        create_month("June")
        |> Month.add_day(%Day{number: 1, name: "Monday"})
        |> Month.days_count()

      assert result == 1
    end

    test "counts multiple days" do
      result =
        create_month("July")
        |> Month.add_day(%Day{number: 1, name: "Monday"})
        |> Month.add_day(%Day{number: 2, name: "Tuesday"})
        |> Month.add_day(%Day{number: 3, name: "Wednesday"})
        |> Month.days_count()

      assert result == 3
    end
  end

  describe "total_minutes/1" do
    test "returns 0 for a month with no days" do
      assert create_month("August") |> Month.total_minutes() == 0
    end

    test "calculates total minutes from a single day" do
      day =
        %Day{number: 1, name: "Monday"}
        |> Day.add_task(%Task{category: "DEV", description: "Fix bug", minutes: 60})
        |> Day.add_task(%Task{category: "DOC", description: "Write docs", minutes: 30})

      result = create_month("September") |> Month.add_day(day) |> Month.total_minutes()

      assert result == 90
    end

    test "calculates total minutes from multiple days" do
      day1 =
        %Day{number: 1, name: "Monday"}
        |> Day.add_task(%Task{category: "DEV", description: "Fix bug", minutes: 60})

      day2 =
        %Day{number: 2, name: "Tuesday"}
        |> Day.add_task(%Task{category: "DOC", description: "Write docs", minutes: 30})
        |> Day.add_task(%Task{category: "COMM", description: "Meeting", minutes: 45})

      day3 = %Day{number: 3, name: "Wednesday", tasks: []}

      result =
        create_month("October")
        |> Month.add_day(day1)
        |> Month.add_day(day2)
        |> Month.add_day(day3)
        |> Month.total_minutes()

      assert result == 135
    end
  end

  describe "minutes_by_category/1" do
    test "returns empty map for a month with no days" do
      assert create_month("December") |> Month.minutes_by_category() == %{}
    end

    test "calculates minutes by category from a single day" do
      task1 = %Task{category: "DEV", description: "Fix", minutes: 60}
      task2 = %Task{category: "DEV", description: "Feature", minutes: 90}
      task3 = %Task{category: "DOC", description: "Docs", minutes: 30}

      day = %Day{number: 1, name: "Monday", tasks: [task1, task2, task3]}
      result = create_month("January") |> Month.add_day(day) |> Month.minutes_by_category()

      assert result == %{"DEV" => 150, "DOC" => 30}
    end

    test "aggregates minutes by category from multiple days" do
      task1 = %Task{category: "DEV", description: "Fix", minutes: 60}
      task2 = %Task{category: "DOC", description: "Docs", minutes: 30}
      task3 = %Task{category: "DEV", description: "Feature", minutes: 40}
      task4 = %Task{category: "COMM", description: "Meeting", minutes: 50}

      day1 = %Day{number: 1, name: "Monday", tasks: [task1, task2]}
      day2 = %Day{number: 2, name: "Tuesday", tasks: [task3, task4]}

      result =
        create_month("February")
        |> Month.add_day(day1)
        |> Month.add_day(day2)
        |> Month.minutes_by_category()

      assert result == %{"DEV" => 100, "DOC" => 30, "COMM" => 50}
    end
  end

  describe "stats/1" do
    test "returns correct stats for a single day" do
      day1 =
        %Day{number: 1, name: "Monday"}
        |> Day.add_task(%Task{category: "DEV", description: "Fix", minutes: 60})
        |> Day.add_task(%Task{category: "DOC", description: "Docs", minutes: 30})

      day2 =
        %Day{number: 2, name: "Tuesday"}
        |> Day.add_task(%Task{category: "DEV", description: "Feature", minutes: 90})

      day3 = %Day{number: 3, name: "Wednesday", tasks: []}

      result =
        create_month("August")
        |> Month.add_day(day1)
        |> Month.add_day(day2)
        |> Month.add_day(day3)
        |> Month.stats()

      assert result.total_minutes == 180
      assert result.days_count == 3
      assert result.minutes_by_category == %{"DEV" => 150, "DOC" => 30}
      assert result.avg_minutes_by_day == 60.0
    end

    test "handles empty month" do
      assert create_month("January") |> Month.stats() == %{
               total_minutes: 0,
               days_count: 0,
               avg_minutes_by_day: 0,
               minutes_by_category: %{}
             }
    end
  end
end
