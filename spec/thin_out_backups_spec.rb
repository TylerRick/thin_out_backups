require 'tmpdir'
require 'rspec'
require_relative '../lib/thin_out_backups'

$now = Time.utc(2008,11,12, 7,45,19)

describe '.time_format' do
  subject { ThinOutBackups::Command.time_format }
  it { expect('db_dump_20080808T0303.sql').to match subject }
  it { expect('db_dump_2008-08-08T0303.sql').to match subject }
  it { expect('db_backup.2016-04-28T01:04.sql.gz').to match subject }
end

describe Time, "#beginning_of_week(:sunday)" do
  it "should return a Sunday" do
    expect(Time.utc(2008,11,12).beginning_of_week(:sunday)).to eq(Time.utc(2008,11,9))
  end
end

describe ThinOutBackups::Command::Bucket, "time interval alignment" do

  def sample_quotas
    {
      :minutely => 1,
      :hourly => 3,
      :daily => 1,
      :weekly => '*',
      :monthly => 1,
      :yearly => '*'
    }
  end

  before do
    @command = ThinOutBackups::Command.new('bogus_dir', sample_quotas)
    @now = $now
    allow(@command).to receive(:now).and_return(@now)
  end

  it "should use the time specified by our test" do
    expect(@command.now).to eq(@now)
  end

  it "hour interval should start on the hour, etc." do
    expect(@command.bucket(:minutely).start_time).to eq(Time.utc(2008,11,12, 7,46,0))
    expect(@command.bucket(:hourly).  start_time).to eq(Time.utc(2008,11,12, 8,0,0))
    expect(@command.bucket(:daily).   start_time).to eq(Time.utc(2008,11,13, 0,0,0))
    expect(@command.bucket(:weekly).  start_time).to eq(Time.utc(2008,11,16, 0,0,0))
    expect(@command.bucket(:monthly). start_time).to eq(Time.utc(2008,12, 1, 0,0,0))
    expect(@command.bucket(:yearly).  start_time).to eq(Time.utc(2009, 1, 1, 0,0,0))
  end

end


$command = <<End
  ruby -Ilib bin/thin_out_backups --force --daily=3 --weekly=3 --monthly=* \
                --no-color \
                --now='#{$now.strftime("%Y-%m-%d %H:%M:%S")}'\
                spec/test_dir/db_dumps \
                spec/test_dir/maildir
End
describe ThinOutBackups::Command, "when calling `#{$command}`" do
  before do
    Pathname.new("spec/test_dir/").rmtree rescue nil

    dir='spec/test_dir/db_dumps/'
    system "mkdir -p #{dir}"
    files = %w[
    db_dump_2008-08-08T0303.sql
    db_dump_2008-09-01T0303.sql
    db_dump_2008-09-10T0303.sql
    db_dump_2008-10-15T0303.sql
    db_dump_2008-10-16T0303.sql
    db_dump_2008-10-17T0303.sql
    db_dump_2008-10-18T0303.sql
    db_dump_2008-10-19T0303.sql
    db_dump_2008-10-20T0303.sql
    db_dump_2008-10-21T0303.sql
    db_dump_2008-10-22T0303.sql
    db_dump_2008-10-23T0303.sql
    db_dump_2008-10-24T0303.sql
    db_dump_2008-10-25T0303.sql
    db_dump_2008-10-26T0303.sql
    db_dump_2008-10-27T0303.sql
    db_dump_2008-10-28T0303.sql
    db_dump_2008-10-29T0303.sql
    db_dump_2008-10-30T0303.sql
    db_dump_2008-10-31T0303.sql
    db_dump_2008-11-01T0303.sql
    db_dump_2008-11-02T0303.sql
    db_dump_2008-11-03T0303.sql
    db_dump_2008-11-04T0303.sql
    db_dump_2008-11-05T0303.sql
    db_dump_2008-11-06T0303.sql
    db_dump_2008-11-07T0303.sql
    db_dump_2008-11-08T0303.sql
    db_dump_2008-11-09T0303.sql
    db_dump_2008-11-10T0303.sql
    db_dump_2008-11-11T0303.sql
    db_dump_2008-11-12T0303.sql
    ]
    files.each do |file|
      Dir.getwd
      #puts %(Dir.getwd=#{(Dir.getwd).inspect})
      #puts %("touch #{dir}/#{file}"=#{("touch #{dir}/#{file}").inspect})
      system "touch #{dir}/#{file}"
    end

    dir='spec/test_dir/maildir/'
    system "mkdir -p #{dir}"
    subdirs = %w[
    2008-11-09T0303
    2008-11-10T0303
    2008-11-11T0303
    ]
    subdirs.each do |subdir|
      system "mkdir -p #{dir}/#{subdir}"
      system "touch    #{dir}/#{subdir}/inbox"
      system "touch    #{dir}/#{subdir}/some_other_folder"
    end

    @output = `#{$command}`
    expect($?.success?).to eq true
  end

  it do
    #puts @output
    expect(@output).to eq <<~End
      Using alternate now: 2008-11-11 23:45:19 -0800
      Processing spec/test_dir/db_dumps/*
      Trying to fill bucket 'daily' (quota: 3)...
      Checking range (2008-11-11 00:00:00 -0800 .. 2008-11-12 00:00:00 -0800)... found keeper db_dump_2008-11-11T0303.sql
      Checking range (2008-11-10 00:00:00 -0800 .. 2008-11-11 00:00:00 -0800)... found keeper db_dump_2008-11-10T0303.sql
      Checking range (2008-11-09 00:00:00 -0800 .. 2008-11-10 00:00:00 -0800)... found keeper db_dump_2008-11-09T0303.sql
      Filled quota!
      Trying to fill bucket 'weekly' (quota: 3)...
      Checking range (2008-11-09 00:00:00 -0800 .. 2008-11-16 00:00:00 -0800)... found keeper db_dump_2008-11-12T0303.sql
      Checking range (2008-11-02 00:00:00 -0700 .. 2008-11-09 00:00:00 -0800)... found keeper db_dump_2008-11-08T0303.sql
      Checking range (2008-10-26 00:00:00 -0700 .. 2008-11-02 00:00:00 -0700)... found keeper db_dump_2008-11-01T0303.sql
      Filled quota!
      Trying to fill bucket 'monthly' (quota: *)...
      Checking range (2008-11-01 00:00:00 -0700 .. 2008-12-01 01:00:00 -0800)... found keeper db_dump_2008-11-12T0303.sql
      Checking range (2008-10-01 00:00:00 -0700 .. 2008-11-01 00:00:00 -0700)... found keeper db_dump_2008-10-31T0303.sql
      Checking range (2008-09-01 00:00:00 -0700 .. 2008-10-01 00:00:00 -0700)... found keeper db_dump_2008-09-10T0303.sql
      Checking range (2008-08-01 00:00:00 -0700 .. 2008-09-01 00:00:00 -0700)... found keeper db_dump_2008-08-08T0303.sql
      spec/test_dir/db_dumps/db_dump_2008-11-12T0303.sql: in buckets: weekly, monthly
      spec/test_dir/db_dumps/db_dump_2008-11-11T0303.sql: in buckets: daily
      spec/test_dir/db_dumps/db_dump_2008-11-10T0303.sql: in buckets: daily
      spec/test_dir/db_dumps/db_dump_2008-11-09T0303.sql: in buckets: daily
      spec/test_dir/db_dumps/db_dump_2008-11-08T0303.sql: in buckets: weekly
      spec/test_dir/db_dumps/db_dump_2008-11-07T0303.sql: delete
      spec/test_dir/db_dumps/db_dump_2008-11-06T0303.sql: delete
      spec/test_dir/db_dumps/db_dump_2008-11-05T0303.sql: delete
      spec/test_dir/db_dumps/db_dump_2008-11-04T0303.sql: delete
      spec/test_dir/db_dumps/db_dump_2008-11-03T0303.sql: delete
      spec/test_dir/db_dumps/db_dump_2008-11-02T0303.sql: delete
      spec/test_dir/db_dumps/db_dump_2008-11-01T0303.sql: in buckets: weekly
      spec/test_dir/db_dumps/db_dump_2008-10-31T0303.sql: in buckets: monthly
      spec/test_dir/db_dumps/db_dump_2008-10-30T0303.sql: delete
      spec/test_dir/db_dumps/db_dump_2008-10-29T0303.sql: delete
      spec/test_dir/db_dumps/db_dump_2008-10-28T0303.sql: delete
      spec/test_dir/db_dumps/db_dump_2008-10-27T0303.sql: delete
      spec/test_dir/db_dumps/db_dump_2008-10-26T0303.sql: delete
      spec/test_dir/db_dumps/db_dump_2008-10-25T0303.sql: delete
      spec/test_dir/db_dumps/db_dump_2008-10-24T0303.sql: delete
      spec/test_dir/db_dumps/db_dump_2008-10-23T0303.sql: delete
      spec/test_dir/db_dumps/db_dump_2008-10-22T0303.sql: delete
      spec/test_dir/db_dumps/db_dump_2008-10-21T0303.sql: delete
      spec/test_dir/db_dumps/db_dump_2008-10-20T0303.sql: delete
      spec/test_dir/db_dumps/db_dump_2008-10-19T0303.sql: delete
      spec/test_dir/db_dumps/db_dump_2008-10-18T0303.sql: delete
      spec/test_dir/db_dumps/db_dump_2008-10-17T0303.sql: delete
      spec/test_dir/db_dumps/db_dump_2008-10-16T0303.sql: delete
      spec/test_dir/db_dumps/db_dump_2008-10-15T0303.sql: delete
      spec/test_dir/db_dumps/db_dump_2008-09-10T0303.sql: in buckets: monthly
      spec/test_dir/db_dumps/db_dump_2008-09-01T0303.sql: delete
      spec/test_dir/db_dumps/db_dump_2008-08-08T0303.sql: in buckets: monthly
      Processing spec/test_dir/maildir/*
      Trying to fill bucket 'daily' (quota: 3)...
      Checking range (2008-11-11 00:00:00 -0800 .. 2008-11-12 00:00:00 -0800)... found keeper 2008-11-11T0303
      Checking range (2008-11-10 00:00:00 -0800 .. 2008-11-11 00:00:00 -0800)... found keeper 2008-11-10T0303
      Checking range (2008-11-09 00:00:00 -0800 .. 2008-11-10 00:00:00 -0800)... found keeper 2008-11-09T0303
      Filled quota!
      Trying to fill bucket 'weekly' (quota: 3)...
      Checking range (2008-11-09 00:00:00 -0800 .. 2008-11-16 00:00:00 -0800)... found keeper 2008-11-11T0303
      Trying to fill bucket 'monthly' (quota: *)...
      Checking range (2008-11-01 00:00:00 -0700 .. 2008-12-01 01:00:00 -0800)... found keeper 2008-11-11T0303
      spec/test_dir/maildir/2008-11-11T0303: in buckets: daily, weekly, monthly
      spec/test_dir/maildir/2008-11-10T0303: in buckets: daily
      spec/test_dir/maildir/2008-11-09T0303: in buckets: daily
    End

    # It keeps/removes the correct files
    expect(Dir['spec/test_dir/db_dumps/*']).to match_array(%w[
      spec/test_dir/db_dumps/db_dump_2008-08-08T0303.sql
      spec/test_dir/db_dumps/db_dump_2008-09-10T0303.sql
      spec/test_dir/db_dumps/db_dump_2008-10-31T0303.sql
      spec/test_dir/db_dumps/db_dump_2008-11-01T0303.sql
      spec/test_dir/db_dumps/db_dump_2008-11-08T0303.sql
      spec/test_dir/db_dumps/db_dump_2008-11-09T0303.sql
      spec/test_dir/db_dumps/db_dump_2008-11-10T0303.sql
      spec/test_dir/db_dumps/db_dump_2008-11-11T0303.sql
      spec/test_dir/db_dumps/db_dump_2008-11-12T0303.sql
    ])
  end

  after do
    #Pathname.new("spec/test_dir/").rmtree rescue nil
  end
end

