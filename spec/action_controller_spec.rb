# Props to @relishapp (http://www.relishapp.com/rspec/rspec-rails/docs/controller-specs/anonymous-controller) and 
# @AlexandrZaytsev (http://say26.com/rspec-testing-controllers-outside-of-a-rails-application) for their helpful blog posts
require 'spec_helper'
require File.dirname(__FILE__) + '/helpers/rails'

RSpec.configure do |c|
  c.infer_base_class_for_anonymous_controllers = true
end

class ApplicationController < ActionController::Base
  include Rails.application.routes.url_helpers
end

class ApplicationControllerSubclass < ApplicationController; end

describe ApplicationControllerSubclass, :type => :controller do
  controller(ApplicationControllerSubclass) do
    def index
      @count = 1/0
    end
  end

  it "should instrument all exceptions not rescued" do
    expect { get :index, {:id => 1, :sort => "name"} }.to raise_error

    last_payload = CopperEgg::APM.send(:class_variable_get, :@@payload_cache).split("\x00").select {|i| i.size > 2}.map {|i| i.sub(/^[^\{]+/,'')}.last
    hash = JSON.parse last_payload

    expect(hash.keys.sort).to eq ["excp", "id"]
    expect(hash["id"]).to match(/\A[0-1a-z]{16}\z/i)
    expect(hash["excp"].keys.sort).to eq ["error", "stacktrace", "ts"]
    expect(hash["excp"]["error"]).to match(/ZeroDivisionError\|/)
    expect(hash["excp"]["stacktrace"]).to match(/\Adivided by 0\n/)
    expect(hash["excp"]["ts"]).to be_an_instance_of(Fixnum)
  end
end
