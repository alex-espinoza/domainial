class ParkIOSoldCSVWorker
  def initialize
    @sold_csv_url = 'https://app.park.io/orders/export.csv'
    @agent = Mechanize.new
    @csv_filename = nil
  end

  def perform
    save_sold_csv_file
    parse_csv_file
    delete_file
  end

  def save_sold_csv_file
    file = @agent.get(@sold_csv_url)
    @csv_filename = file.save("tmp/csv/#{file.filename}")
  end

  def parse_csv_file
    # do not load whole file into memory, read line by line
    CSV.foreach(@csv_filename, {headers: true}) do |line|
      CompetitorDomainSoldWorker.perform_async(line['Domain'], line['Date'], line['Amount (USD)'], 'park.io')
    end
  end

  def delete_file
    File.delete(@csv_filename)
  end
end
