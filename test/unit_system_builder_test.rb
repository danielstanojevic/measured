require "test_helper"

class Measured::UnitSystemBuilderTest < ActiveSupport::TestCase
  test "#unit adds a new unit" do
    measurable = Measured.build do
      unit :m
      unit :in, aliases: [:inch], value: "0.0254 m"
    end

    assert_equal 2, measurable.unit_names.count
  end

  test "#unit cannot add duplicate unit names" do
    assert_raises Measured::UnitError do
      Measured.build do
        unit :m
        unit :in, aliases: [:inch], value: "0.0254 m"
        unit :in, aliases: [:thing], value: "123 m"
      end
    end

    assert_raises Measured::UnitError do
      Measured.build do
        unit :m
        unit :in, aliases: [:inch], value: "0.0254 m"
        unit :inch, aliases: [:thing], value: "123 m"
      end
    end
  end

  test "#unit is case sensitive" do
    measurable = Measured.build do
      unit :normal
      unit :bold, value: "10 normal"
      unit :BOLD, value: "100 normal"
    end

    assert_equal 'BOLD', measurable.unit_system.unit_for!(:BOLD).name
  end
end
