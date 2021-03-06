Point = require "../src/point"
TransformLayer = require "../src/transform-layer"
LinesTransform = require "../src/lines-transform"
StringLayer = require "../spec/string-layer"

describe "TransformLayer", ->
  describe "::getLines()", ->
    it "returns the content as an array of lines", ->
      stringLayer = new StringLayer("\nabc\ndefg\n")
      layer = new TransformLayer(stringLayer, new LinesTransform)

      expect(layer.getLines()).toEqual [
        "\n"
        "abc\n"
        "defg\n"
        ""
      ]

  describe "::slice(start, end)", ->
    it "returns the content between the start and end points", ->
      stringLayer = new StringLayer("\nabc\ndefg\n")
      layer = new TransformLayer(stringLayer, new LinesTransform)

      expect(layer.slice(Point(0, 0), Point(1, 0))).toBe "\n"
      expect(layer.slice(Point(0, 0), Point(1, 1))).toBe "\na"
      expect(layer.slice(Point(1, 1), Point(2, 1))).toBe "bc\nd"
      expect(layer.slice(Point(1, 0), Point(2, 0))).toBe "abc\n"

  describe "::splice(start, extent, content)", ->
    it "splices into the underlying layer with a translated start and extent", ->
      stringLayer = new StringLayer("\nabc\ndefg\n")
      layer = new TransformLayer(stringLayer, new LinesTransform)

      newExtent = layer.splice(Point(1, 2), Point(1, 2), "xyz")
      expect(newExtent).toEqual Point(0, 3)
      expect(layer.getLines()).toEqual [
        "\n"
        "abxyzfg\n",
        ""
      ]

      newExtent = layer.splice(Point(1, 2), Point(0, 0), "123\n4")
      expect(newExtent).toEqual Point(1, 1)
      expect(layer.getLines()).toEqual [
        "\n"
        "ab123\n"
        "4xyzfg\n",
        ""
      ]

  describe "when the input layer's content changes", ->
    it "emits an event and returns content based on the new input content", ->
      stringLayer = new StringLayer("\nabc\ndefg\n")
      layer = new TransformLayer(stringLayer, new LinesTransform)

      events = []
      layer.onDidChange (event) -> events.push(event)

      stringLayer.splice(Point(0, "\nabc\nd".length), Point(0, 1), "x\nyz")

      expect(layer.getLines()).toEqual [
        "\n"
        "abc\n"
        "dx\n"
        "yzfg\n"
        ""
      ]

      expect(events).toEqual([{
        position: Point(2, 1)
        oldExtent: Point(0, 1)
        newExtent: Point(1, 2)
      }])
