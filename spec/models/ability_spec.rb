require "spec_helper"

describe Ability do
  describe "as guest" do
    subject { Ability.new(nil) }
    it { should be_able_to(:read, Channel) }
    it { should be_able_to(:index, Video) }
    it { should_not be_able_to(:create, Channel) }
    it { should_not be_able_to(:update, Channel) }
    it { should_not be_able_to(:approve, Video) }
    it { should_not be_able_to(:moderate, Channel) }
  end

  describe "as a user owning a channel" do
    before do
      @user = FactoryGirl.build :user
      @channel = FactoryGirl.build :channel, user: @user
      @other_channel = FactoryGirl.build :channel
    end

    subject { Ability.new(@user) }
    it { should be_able_to(:update, @channel) }
    it { should_not be_able_to(:update, @other_channel) }

    describe "with a plan that allows embeds" do
      before do
        @plan = FactoryGirl.build :plan, embed: true
        @user.plan = @plan
      end

      it { should be_able_to(:embed, @channel) }
    end

    describe "with a plan that doesn't allow embeds" do
      before do
        @plan = FactoryGirl.build :plan, embed: false
        @user.plan = @plan
      end

      it { should_not be_able_to(:embed, @channel) }
    end

    describe "with a plan that doesn't allow moderation" do
      before do
        @plan = FactoryGirl.build :plan, moderation: false
        @user.plan = @plan
        @video = FactoryGirl.build :video, channel: @channel
      end

      it { should_not be_able_to(:moderate, @channel) }
      it { should_not be_able_to(:approve, @video) }
      it { should_not be_able_to(:deny, @video) }
    end

    describe "with a plan that does allow moderation" do
      before do
        @plan = FactoryGirl.build :plan, moderation: true
        @user.plan = @plan
        @video = FactoryGirl.build :video, channel: @channel
        @other_video = FactoryGirl.build :video
      end

      it { should be_able_to(:moderate, @channel) }
      it { should be_able_to(:approve, @video) }
      it { should be_able_to(:deny, @video) }
      it { should_not be_able_to(:approve, @other_video) }
    end

    describe "with a plan that doesn't allow custom branding" do
      before do
        @plan = FactoryGirl.build :plan, branding: false
        @user.plan = @plan
      end

      it { should_not be_able_to(:brand, @channel) }
    end

    describe "with a plan that does allow custom branding" do
      before do
        @plan = FactoryGirl.build :plan, branding: true
        @user.plan = @plan
      end

      it { should be_able_to(:brand, @channel) }
    end
  end
end
