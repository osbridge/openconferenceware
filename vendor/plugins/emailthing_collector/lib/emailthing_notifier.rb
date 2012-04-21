require 'thread'
class EmailthingNotifier

  def self.queue
    @queue ||= Queue.new
  end

  def self.link_clicked(et_id)
    queue << et_id
    start_processor_if_not_running
  end

  def self.start_processor_if_not_running
    @consumer ||= Thread.new do
      process_from_queue
    end
  end

  def self.process_et_id(et_id)
    Net::HTTP.get(URI.parse("http://ping.emailthing.net/l/#{et_id}"))
  end

  def self.process_from_queue
    while true
      process_et_id(queue.pop)
    end
  end

end