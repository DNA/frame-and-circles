json.id @frame.id
json.x @frame.x.to_f
json.y @frame.y.to_f
json.width @frame.width.to_f
json.height @frame.height.to_f

json.circle_positions do
  json.topmost @frame.circles.topmost.presence || []
  json.bottommost @frame.circles.bottommost || []
  json.leftmost @frame.circles.leftmost || []
  json.rightmost @frame.circles.rightmost || []
end
