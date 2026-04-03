require "sidekiq"
require "sidekiq-scheduler"
require "yaml"

Sidekiq.configure_server do |config|
  schedule_config = YAML.load_file(Rails.root.join("config/sidekiq.yml"))
  schedule = schedule_config.fetch(:scheduler, {}).fetch(:schedule, {})

  Sidekiq.schedule = schedule if schedule.present?
  SidekiqScheduler::Scheduler.instance.reload_schedule!
end
