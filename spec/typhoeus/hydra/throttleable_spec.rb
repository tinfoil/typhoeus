require 'spec_helper'
require 'timecop'

describe Typhoeus::Hydra::Throttleable do
  let(:base_url) { "localhost:3001" }
  let(:options) { {:requests_per_second => 2} }
  let(:hydra) { Typhoeus::Hydra.new(options) }

  describe "#throttling_enabled?" do
    context "when requests_per_second is set" do
      specify do
        hydra.throttling_enabled?.should be true
      end
    end
    context "when requests_per_second is not set" do
      let(:options) { {} }
      specify do
        hydra.throttling_enabled?.should be false
      end
    end
  end

  describe "#add" do
    let(:request) { Typhoeus::Request.new("localhost:3001/first") }

    it "should add a timestamp to the queue" do
      hydra.add(request)
      hydra.instance_variable_get(:@throttle_buffer).size.should eq(1)
    end
  end

  describe "#available_throttled_capacity" do
    let(:first) { Typhoeus::Request.new("localhost:3001/first") }
    let(:second) { Typhoeus::Request.new("localhost:3001/second") }

    before { Timecop.freeze }

    context "when no requests have been added" do
      specify do
        hydra.available_throttled_capacity.should eq(2)
      end
    end

    context "when the buffer is full" do
      before do
        hydra.add(first)
        hydra.add(second)
      end

      specify do
        hydra.available_throttled_capacity.should eq(0)
      end
    end

    context "after some time has passed to only empty some of the buffer" do
      before do
        hydra.add(first)
        Timecop.travel(Time.now + 0.5)
        hydra.add(second)
      end

      specify do
        Timecop.travel(Time.now + 0.51)
        hydra.available_throttled_capacity.should eq(1)
      end
    end

    context "after enough time has passed to empty the buffer" do
      before do
        hydra.add(first)
        hydra.add(second)
      end

      specify do
        Timecop.travel(Time.now + 2)
        hydra.available_throttled_capacity.should eq(2)
      end
    end
  end
end
