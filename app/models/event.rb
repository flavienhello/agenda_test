class Event < ActiveRecord::Base


  scope :openings, -> { where kind: 'opening' }
  scope :appointments, -> { where kind: 'appointment' }

  # Until how long ago we can find an opening event
  PAST_DATE_LIMIT = DateTime.parse("2014-01-01")
  # The length of one rdv
  RDV_LENGTH_CUT = 30


  def self.availabilities( wanted_date=DateTime.parse("2014-08-10") )
    puts "ASK RDV FOR DATE: #{wanted_date.to_date}"
    weekly_availabilities = []
    7.times.each do |i|
      weekly_availabilities << calculate_daily_availabilities(wanted_date + i)
    end
    weekly_availabilities
  end

  def self.calculate_daily_availabilities( wanted_date )

    # This calculate every days an opening could have been open in the past so that it would be open to this date
    list = create_past_weekly_list wanted_date
    slots = []

    # Calculate opening in the past
    openings = Event.openings.where( weekly_recurring: true, starts_at: list )
    openings += Event.openings.where( 'starts_at BETWEEN ? AND ? OR ends_at BETWEEN ? AND ?', wanted_date, (wanted_date+1.day), wanted_date, (wanted_date+1.day) )
    openings.each do |open|
      d1 = open.starts_at
      d2 = open.ends_at
      start_time = DateTime.new( wanted_date.year, wanted_date.month, wanted_date.day, d1.hour, d1.min )
      end_time = DateTime.new( wanted_date.year, wanted_date.month, wanted_date.day, d2.hour, d2.min )
      # Build every time slot depending on the slice time
      build_time_slots( start_time, end_time, slots )
    end

    # Finds appointments starting or finishing that day
    appointments = Event.appointments.where('starts_at BETWEEN ? AND ? OR ends_at BETWEEN ? AND ?', wanted_date, (wanted_date+1.day), wanted_date, (wanted_date+1.day))
    appointments.each do |open|
      d1 = open.starts_at
      d2 = open.ends_at
      slots.reject! do |s|
        s2 = s + RDV_LENGTH_CUT.minutes
        # Starts during a slot / Ends during a slot / Or start before it and ends after it
        (d1 >= s && d1 < s2) || (d2 > s && d2 <= s2) || (d1 < s && d2 > s2)
      end
    end

    # Is there an open slot for our day ?
    # Sort and Change display
    ava_array = slots.sort.map { |s| s.strftime('%k:%M').strip } || []
    { date: wanted_date.to_date, slots: ava_array }
  end

  def self.build_time_slots( start_time, end_time, slots )
    slot = start_time
    while slot < end_time
      slots << slot unless slots.include?(slot)
      slot += RDV_LENGTH_CUT.minutes
    end
    slots.sort
  end

  # This calculate every days an opening could have been open in the past so that it would be open to this date
  def self.create_past_weekly_list( wanted_date)
    dates = []
    while wanted_date >= PAST_DATE_LIMIT
      wanted_date_end = wanted_date + 1.day
      dates << (wanted_date..wanted_date_end)
      wanted_date = wanted_date.to_date - 7.day
    end
    dates
  end


end
