require 'rails_helper'

RSpec.describe Appointment, type: :model do
  describe "validation" do
    before(:each) do
      @appointment = Appointment.new
    end

    it "fails to create without sex" do
      @appointment.age = 42

      expect(@appointment).not_to be_valid
    end

    it "fails to create without age" do
      @appointment.sex = "female"

      expect(@appointment).not_to be_valid
    end

    it "fails to create when age is not number" do
      @appointment.age = "quarenta e dois"
      @appointment.sex = "female"

      expect(@appointment).not_to be_valid
    end

    it "fails to create when sex isn't exactally male or female" do
      @appointment.age = 42
      @appointment.sex = "male anything"

      expect(@appointment).not_to be_valid
    end

    it "accepts ' MALE ' as a valid sex" do
      @appointment.age = 42
      @appointment.sex = " MALE "

      expect(@appointment).to be_valid
    end
    
    it "accepts ' FEMALE ' as a valid sex" do
      @appointment.age = 37
      @appointment.sex = " FEMALE "

      expect(@appointment).to be_valid
    end
  end

  describe "query methods" do
    before(:each) do
      Appointment.delete_all
      @valid_period_date = 4.days.ago
    end

    describe "age_distribution" do
      it "is defined" do
        expect(Appointment).to respond_to(:age_distribution)
      end

      it "always returns a Hash" do
        expect(Appointment.age_distribution).to be_a(Hash)

        Appointment.create([
          { sex: "male", age: 40 },
          { sex: "female", age: 80 },
          { sex: "male", age: 60 },
        ])

        expect(Appointment.age_distribution).to be_a(Hash)
      end

      it "returns an empty hash when there is no data" do
        expect(Appointment.age_distribution).to eql({})
      end

      it "return the correct counting when there is data" do
        Appointment.create([
          { age: 40, sex: "male" },
          { age: 45, sex: "female" },
          { age: 40, sex: "female" },
        ])

        expect(Appointment.age_distribution).to eql({ 40 => 2, 45 => 1 })
      end
    end

    describe "sex_per_last_period" do
      it "is defined" do
        expect(Appointment).to respond_to(:sex_per_last_period)
      end

      it "requires a date parameter prior to tomorrow" do
        expect { Appointment.sex_per_last_period }.to raise_error(ArgumentError)
        expect { Appointment.sex_per_last_period((Time.now + 2.days)) }.to raise_error(ArgumentError)
        expect { Appointment.sex_per_last_period(Time.now) }.not_to raise_error
      end

      it "returns an empty hash when no data is present" do
        expect(Appointment.sex_per_last_period(@valid_period_date)).to eql({})
      end

      it "return correct counts when there is data" do
        the_counts = {
          ["male", 3.days.ago.to_date] => 1,
          ["female", 3.days.ago.to_date] => 1,
          ["female", 2.days.ago.to_date] => 1,
        }

        Appointment.create([
          { sex: "male", age: 40, created_at: 3.days.ago },
          { sex: "female", age: 62, created_at: 3.days.ago },
          { sex: "female", age: 37, created_at: 2.days.ago },
        ])

        expect(Appointment.sex_per_last_period(@valid_period_date)).to eql(the_counts)
      end
    end
  end
end
