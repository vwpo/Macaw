
import UIKit
import Macaw

class PathExampleView: MacawView {

	var animation: Animation?
	let sceneGroup: Group
	let initialTransform: Transform

	var onScaleUpdate: ((Double) -> ())?

	required init?(coder aDecoder: NSCoder) {

		let startPoint = Point(x: 150.0, y: 150.0)

		func cloudExample() -> Group {
			func cloud1() -> Path {
				return MoveTo(x: 441.953, y: 142.352)
					.c(-4.447, -68.872, -61.709, -123.36, -131.705, -123.36)
					.c(-59.481, 0, -109.766, 39.346, -126.264, 93.429)
					.c(-9.244, -3.5, -19.259, -5.431, -29.729, -5.431)
					.c(-42.84, 0, -78.164, 32.08, -83.322, 73.523)
					.c(-0.309, -0.004, -0.614, -0.023, -0.924, -0.023)
					.c(-36.863, 0, -66.747, 29.883, -66.747, 66.747)
					.s(29.883, 66.746, 66.747, 66.746)
					.c(4.386, 0, 8.669, -0.436, 12.819, -1.243)
					.c(20.151, 27.069, 52.394, 44.604, 88.734, 44.604)
					.c(31.229, 0, 59.429, -12.952, 79.533, -33.772)
					.c(15.071, 15.091, 35.901, 24.428, 58.913, 24.428)
					.c(31.43, 0, 58.783, -17.42, 72.955, -43.127)
					.c(11.676, 5.824, 24.844, 9.106, 38.777, 9.106)
					.c(48.047, 0, 86.998, -38.949, 86.998, -86.996)
					.C(508.738, 185.895, 480.252, 151.465, 441.953, 142.352)
					.Z().build()
			}

			func cloud2() -> Path {
				return MoveTo(x: 431.357, y: 266.878)
					.c(0.058, -1.449, 0.187, -2.878, 0.187, -4.333)
					.c(0, -74.304, -60.587, -134.545, -135.315, -134.545)
					.c(-54.09, 0, -100.571, 31.647, -122.229, 77.266)
					.c(-11.06, -7.422, -24.343, -11.812, -38.686, -11.812)
					.c(-36.586, 0, -66.518, 28.14, -69.214, 63.836)
					.C(27.625, 270.685, 0, 306.991, 0, 349.819)
					.C(0, 404.045, 44.2, 448, 98.743, 448)
					.h(321.828)
					.C(471.057, 448, 512, 407.29, 512, 357.091)
					.C(512, 310.514, 476.757, 272.184, 431.357, 266.878)
					.Z().build()
			}

			func lightning() -> Path {
				return MoveTo(x: 0, y: 0)
					.lineTo(x: 23, y: 23)
					.lineTo(x: 11, y: 27)
					.lineTo(x: 55, y: 70)
					.lineTo(x: 31, y: 31)
					.lineTo(x: 42, y: 27)
					.lineTo(x: 20, y: 0)
					.close().build()
			}

			let cloud2Shape = Shape(
				form: cloud2(),
				place: Transform.scale(sx: 1.5, sy: 1.5).move(dx: 0, dy: -100),
				fill: Color(val: 0x60636e),
				stroke: Stroke(
					fill: Color(val: 0x7e8087),
					width: 2,
					cap: .round,
					join: .round
				)
			)

			let lightningShape = Shape(
				form: lightning(),
				place: Transform.move(dx: 375, dy: 390).scale(sx: 3, sy: 3),
				fill: LinearGradient(
					userSpace: true,
					stops: [
						Stop(offset: 0, color: Color.rgb(r: 250, g: 220, b: 0)),
						Stop(offset: 1, color: Color(val: 0xeb6405))
					],
					y2: 1
				)
			)

			let cloud1Shape = Shape(
				form: cloud1(),
				place: .move(dx: 120, dy: 120),
				fill: LinearGradient(
					userSpace: false,
					stops: [
						Stop(offset: 0, color: Color(val: 0x2f3036)),
						Stop(offset: 1, color: Color.rgba(r: 47, g: 48, b: 54, a: 0.1))
					],
					y2: 1
				)
			)

			let cloud1Shape2 = Shape(
				form: cloud1(),
				place: .move(dx: 120, dy: 100),
				fill: Color(val: 0x7b808c),
				stroke: Stroke(
					fill: Color(val: 0xaaacb3),
					width: 1,
					cap: .round,
					join: .round
				)
			)

			return Group(
				contents: [cloud2Shape, lightningShape, cloud1Shape, cloud1Shape2],
				place: Transform.move(dx: startPoint.x, dy: startPoint.y).scale(sx: 1.0, sy: 1.0)
			)
		}

		initialTransform = Transform().move(dx: -50.0, dy: 30.0).scale(sx: 0.5, sy: 0.5)
		sceneGroup = Group(contents: [cloudExample()])
		sceneGroup.place = initialTransform

		let rotation = GeomUtils.centerRotation(node: sceneGroup, place: initialTransform, angle: M_PI_4 / 2.0)
		let superposition = GeomUtils.concat(t1: initialTransform, t2: GeomUtils.concat(t1: rotation, t2: initialTransform))
		// animation = sceneGroup.placeVar.animation((initialTransform >> rotation).t(10.0))

		super.init(node: PathExampleView.newScene(), coder: aDecoder)

		sceneGroup.placeVar.asObservable().subscribeNext { transform in
			let a = transform.m11
			let b = transform.m12
			let sx = a / fabs(a) * sqrt(a * a + b * b)

			self.onScaleUpdate?(sx)
		}
	}

	func testAnimation() {
		dispatch_after(dispatch_time(DISPATCH_TIME_NOW, Int64(1 * NSEC_PER_SEC)), dispatch_get_main_queue()) {
			self.animation?.play()
		}
	}

	func updateScale(scale: Float) {
		let rotation = GeomUtils.centerRotation(node: sceneGroup, place: initialTransform, angle: M_PI_4 * Double(scale))
		sceneGroup.place = rotation// GeomUtils.concat(t1: rotation, t2: initialTransform)
	}

	private static func newScene() -> Node {
		let shape = Shape(form: Rect(x: -50, y: -50, w: 100, h: 100), fill: Color.blue)
		let t1 = Transform.identity
		let t2 = GeomUtils.centerRotation(node: shape, place: Transform.identity, angle: M_PI_4) // Transform.rotate(angle: M_PI_4)
		_ = shape.onTap.subscribeNext { tap in
			shape.placeVar.animate(from: t1, to: t2, during: 2.0)
		}
		return Group(contents: [shape], place: .move(dx: 200, dy: 200))
	}
}
