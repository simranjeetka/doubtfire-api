require 'icalendar'

class Webcal < ActiveRecord::Base
  belongs_to :user

  #
  # Generates a single `Icalendar::Calendar` object from this `Webcal` including calendar events for the specified
  # collection of `TaskDefinition`s.
  #
  # The `unit` property of each `TaskDefinition` is accessed; ensure it is included to prevent N+1 selects. For example,
  #
  #   to_ical_with_task_definitions(
  #     TaskDefinition
  #       .joins(:unit)
  #       .includes(:unit)
  #   )
  #
  def to_ical_with_task_definitions(defs = [])
    ical = Icalendar::Calendar.new

    # Add iCalendar events for the specified definition.
    defs.each  do |td|
      # Note: Start and end dates of events are equal because the calendar event is expected to be an "all-day" event.

      ev_name = "#{td.unit.code}: #{td.abbreviation}: #{td.name}"

      # Add event for start date, if the user opted in.
      if include_start_dates
        ical.event do |ev|
          ev.summary = "Start: #{ev_name}"
          ev.dtstart = ev.dtend = Icalendar::Values::Date.new(td.start_date.strftime('%Y%m%d'))
        end
      end

      # Add event for target/extended date.
      # TODO: Use extension date if available.
      ical.event do |ev|
        ev.summary = "#{include_start_dates ? 'End:' : ''}#{ev_name}"
        ev.dtstart = ev.dtend = Icalendar::Values::Date.new(td.target_date.strftime('%Y%m%d'))
      end
    end

    ical
  end
end
