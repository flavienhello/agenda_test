require 'test_helper'

class EventTest < ActiveSupport::TestCase

  test "one simple test example" do
    Event.create kind: 'opening', starts_at: DateTime.parse("2014-08-04 09:30"), ends_at: DateTime.parse("2014-08-04 13:30"), weekly_recurring: true
    Event.create kind: 'appointment', starts_at: DateTime.parse("2014-08-11 10:30"), ends_at: DateTime.parse("2014-08-11 11:30")

    availabilities = Event.availabilities DateTime.parse("2014-08-10")
    puts availabilities
    puts "\n ########  \n\n"

    assert_equal Date.new(2014, 8, 10), availabilities[0][:date]
    assert_equal [], availabilities[0][:slots]
    assert_equal Date.new(2014, 8, 11), availabilities[1][:date]
    assert_equal ["9:30", "10:00", "11:30", "12:00", "12:30", "13:00"], availabilities[1][:slots]
    assert_equal Date.new(2014, 8, 16), availabilities[6][:date]
    assert_equal 7, availabilities.length
  end

  test "appointment overlapping two days" do
    Event.create kind: 'opening', starts_at: DateTime.parse("2014-08-04 09:30"), ends_at: DateTime.parse("2014-08-04 13:30"), weekly_recurring: true
    Event.create kind: 'appointment', starts_at: DateTime.parse("2014-08-11 10:30"), ends_at: DateTime.parse("2014-08-11 11:30")
    Event.create kind: 'appointment', starts_at: DateTime.parse("2014-08-10 17:30"), ends_at: DateTime.parse("2014-08-11 10:00")

    availabilities = Event.availabilities DateTime.parse("2014-08-10")
    puts availabilities
    puts "\n ########  \n\n"

    assert_equal Date.new(2014, 8, 10), availabilities[0][:date]
    assert_equal [], availabilities[0][:slots]
    assert_equal Date.new(2014, 8, 11), availabilities[1][:date]
    assert_equal ["10:00", "11:30", "12:00", "12:30", "13:00"], availabilities[1][:slots]
  end

  test "opening overlapings" do

    Event.create kind: 'opening', starts_at: DateTime.parse("2014-07-21 11:30"), ends_at: DateTime.parse("2014-07-28 15:30"), weekly_recurring: true
    Event.create kind: 'opening', starts_at: DateTime.parse("2014-07-28 11:30"), ends_at: DateTime.parse("2014-07-28 15:30"), weekly_recurring: true
    Event.create kind: 'opening', starts_at: DateTime.parse("2014-08-04 09:30"), ends_at: DateTime.parse("2014-08-04 13:30"), weekly_recurring: true

    Event.create kind: 'appointment', starts_at: DateTime.parse("2014-08-11 10:30"), ends_at: DateTime.parse("2014-08-11 11:30")
    Event.create kind: 'appointment', starts_at: DateTime.parse("2014-08-11 12:00"), ends_at: DateTime.parse("2014-08-11 12:30")

    availabilities = Event.availabilities DateTime.parse("2014-08-10")
    puts availabilities
    puts "\n ########  \n\n"

    assert_equal Date.new(2014, 8, 10), availabilities[0][:date]
    assert_equal [], availabilities[0][:slots]
    assert_equal Date.new(2014, 8, 11), availabilities[1][:date]
    assert_equal ["9:30", "10:00", "11:30", "12:30", "13:00", "13:30","14:00", "14:30", "15:00"], availabilities[1][:slots]
  end

  test "wrong length for appointment" do

    Event.create kind: 'opening', starts_at: DateTime.parse("2014-08-04 09:30"), ends_at: DateTime.parse("2014-08-04 13:30"), weekly_recurring: true
    Event.create kind: 'appointment', starts_at: DateTime.parse("2014-08-11 10:30"), ends_at: DateTime.parse("2014-08-11 11:45")

    availabilities = Event.availabilities DateTime.parse("2014-08-10")
    puts availabilities
    puts "\n ########  \n\n"

    assert_equal Date.new(2014, 8, 10), availabilities[0][:date]
    assert_equal [], availabilities[0][:slots]
    assert_equal Date.new(2014, 8, 11), availabilities[1][:date]
    assert_equal ["9:30", "10:00", "12:00", "12:30", "13:00"], availabilities[1][:slots]
  end


  test "odd start and end for appointment" do
    Event.create kind: 'opening', starts_at: DateTime.parse("2014-08-04 09:30"), ends_at: DateTime.parse("2014-08-04 13:30"), weekly_recurring: true
    Event.create kind: 'appointment', starts_at: DateTime.parse("2014-08-11 10:35"), ends_at: DateTime.parse("2014-08-11 11:05")

    Event.create kind: 'opening', starts_at: DateTime.parse("2014-08-05 09:30"), ends_at: DateTime.parse("2014-08-05 13:30"), weekly_recurring: true
    Event.create kind: 'appointment', starts_at: DateTime.parse("2014-08-12 10:35"), ends_at: DateTime.parse("2014-08-12 11:00")

    Event.create kind: 'opening', starts_at: DateTime.parse("2014-08-06 09:30"), ends_at: DateTime.parse("2014-08-06 13:30"), weekly_recurring: true
    Event.create kind: 'appointment', starts_at: DateTime.parse("2014-08-13 10:30"), ends_at: DateTime.parse("2014-08-13 11:01")

    availabilities = Event.availabilities DateTime.parse("2014-08-10")
    puts availabilities
    puts "\n ########  \n\n"

    assert_equal Date.new(2014, 8, 10), availabilities[0][:date]
    assert_equal [], availabilities[0][:slots]
    assert_equal Date.new(2014, 8, 11), availabilities[1][:date]
    assert_equal ["9:30", "10:00", "11:30", "12:00", "12:30", "13:00"], availabilities[1][:slots]
    assert_equal Date.new(2014, 8, 12), availabilities[2][:date]
    assert_equal ["9:30", "10:00", "11:00", "11:30", "12:00", "12:30", "13:00"], availabilities[2][:slots]
    assert_equal Date.new(2014, 8, 13), availabilities[3][:date]
    assert_equal ["9:30", "10:00", "11:30", "12:00", "12:30", "13:00"], availabilities[3][:slots]
  end

  test "not weekly recurring" do


      Event.create kind: 'opening', starts_at: DateTime.parse("2014-08-05 09:30"), ends_at: DateTime.parse("2014-08-05 10:30"), weekly_recurring: true
      Event.create kind: 'opening', starts_at: DateTime.parse("2014-08-12 11:30"), ends_at: DateTime.parse("2014-08-12 13:30"), weekly_recurring: false

      # Event.create kind: 'appointment', starts_at: DateTime.parse("2014-08-11 10:35"), ends_at: DateTime.parse("2014-08-11 11:05")
      Event.create kind: 'appointment', starts_at: DateTime.parse("2014-08-12 10:29"), ends_at: DateTime.parse("2014-08-12 12:30")

      availabilities = Event.availabilities DateTime.parse("2014-08-10")
      puts availabilities
      puts "\n ########  \n\n"

      assert_equal Date.new(2014, 8, 10), availabilities[0][:date]
      assert_equal [], availabilities[0][:slots]
      assert_equal Date.new(2014, 8, 11), availabilities[1][:date]
      assert_equal [], availabilities[1][:slots]
      assert_equal Date.new(2014, 8, 12), availabilities[2][:date]
      assert_equal ["9:30", "12:30", "13:00"], availabilities[2][:slots]
  end

end
