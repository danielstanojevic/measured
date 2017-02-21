require "test_helper"

class Measured::BaseUnitTest < ActiveSupport::TestCase
  setup do
    @unit = Measured::BaseUnit.new(:Pie, value: "10 Cake")
    @unit_with_aliases = Measured::BaseUnit.new(:Pie, aliases: %w(Cake Tart))
  end

  test "#initialize converts the name to a string" do
    assert_equal "Pie", @unit.name
  end

  test "#initialize converts aliases to strings and makes a list of sorted names" do
    assert_equal %w(Cake pie sweets), Measured::BaseUnit.new(:pie, aliases: ["Cake", :sweets]).names
  end

  test "#initialize parses out the unit and the number part" do
    assert_equal 10, @unit.conversion_amount
    assert_equal "Cake", @unit.conversion_unit

    unit = Measured::BaseUnit.new(:pie, value: ["5.5", "sweets"])
    assert_equal BigDecimal("5.5"), unit.conversion_amount
    assert_equal "sweets", unit.conversion_unit

    unit = Measured::BaseUnit.new(:pie, value: "1/3 bitter pie")
    assert_equal Rational(1, 3), unit.conversion_amount
    assert_equal "bitter pie", unit.conversion_unit
  end

  test "#initialize raises if the format of the value is incorrect" do
    assert_raises Measured::UnitError do
      Measured::BaseUnit.new(:pie, value: "hello")
    end

    assert_raises Measured::UnitError do
      Measured::BaseUnit.new(:pie, value: "123456")
    end
  end

  test "#to_s returns an expected string" do
    assert_equal "pie", Measured::BaseUnit.new(:pie).to_s
    assert_equal "pie (1/2 sweet)", Measured::BaseUnit.new(:pie, aliases: ["cake"], value: "0.5 sweet").to_s
  end

  test "#inspect returns an expected string" do
    assert_equal "#<Measured::BaseUnit: pie>", Measured::BaseUnit.new(:pie).inspect
    assert_equal "#<Measured::BaseUnit: pie (cake, semi-sweet)>", Measured::BaseUnit.new(:pie, aliases: ["cake", "semi-sweet"]).inspect
    assert_equal "#<Measured::BaseUnit: pie 1/2 sweet>", Measured::BaseUnit.new(:pie, value: "1/2 sweet").inspect
    assert_equal "#<Measured::BaseUnit: pie (cake) 1/2 sweet>", Measured::BaseUnit.new(:pie, aliases: ["cake"], value: "1/2 sweet").inspect
  end

  test "includes Comparable mixin" do
    assert Measured::BaseUnit.ancestors.include?(Comparable)
  end

  test "#<=> compares non-Unit classes against name" do
    assert_equal 1, @unit <=> "Pap"
    assert_equal -1, @unit <=> "Pop"
  end

  test "#<=> is 0 for Unit instances that should be equivalent" do
    assert_equal 0, @unit <=> Measured::BaseUnit.new(:Pie, value: "10 cake")
    assert_equal 0, @unit <=> Measured::BaseUnit.new("Pie", value: "10 cake")
    assert_equal 0, @unit <=> Measured::BaseUnit.new("Pie", value: [10, :cake])
  end

  test "#<=> is -1 for units with names that come after Pie lexicographically" do
    assert_equal -1, @unit <=> Measured::BaseUnit.new(:Pigs, value: "10 bacon")
    assert_equal -1, @unit <=> Measured::BaseUnit.new("Pig", aliases: %w(Pigs), value: "10 bacon")
  end

  test "#<=> compares #conversion_amount when unit names the same" do
    assert_equal -1, @unit <=> Measured::BaseUnit.new(:Pie, value: [11, :pancake])
    assert_equal 0, @unit <=> Measured::BaseUnit.new(:Pie, value: [10, :foo])
    assert_equal 1, @unit <=> Measured::BaseUnit.new(:Pie, value: [9, :pancake])
  end

  test "#inverse_conversion_amount returns 1/amount" do
    assert_equal Rational(1, 10), @unit.inverse_conversion_amount
  end
end