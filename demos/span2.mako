## /* -*- javascript -*-

<%! draggable=True %>
<%! clip_shader=True %>

<%inherit file="base.mako"/>

<%block name="title">Span of two vectors</%block>

<%block name="inline_style">
  #span-type {
      border: solid 1px white;
      padding: 2px;
  }
</%block>

## */

var paramsQS = Demo.prototype.decodeQS();

new Demo({
    mathbox: {
        plugins: ['core', 'controls'],
        controls: {
            klass: THREE.OrbitControls,
            parameters: {
                // noZoom: true,
            }
        },
        mathbox: {
            warmup: 10,
            splash: true,
            inspect: false,
        },
        splash: {fancy: true, color: "blue"},
    },
    camera: {
        proxy:     true,
        position: [-1.5, 1.5, -3],
        lookAt:   [0, 0, 0],
        up:       [0, 1, 0]
    },
    grid: false,
    caption: '&nbsp;',

}, function() {
    var self = this;

    // gui
    var Params = function() {
        this.a = 1.0;
        this.b = 1.0;
        this['Show a.v1 + b.v2'] = false;
        this.Axes = true;
    };
    var params = new Params();
    var gui = new dat.GUI();
    var doAxes = gui.add(params, 'Axes');
    var checkbox = gui.add(params, 'Show a.v1 + b.v2');
    gui.add(params, 'a', -2, 2).step(0.05);
    gui.add(params, 'b', -2, 2).step(0.05);

    checkbox.onFinishChange(function(val) {
        mathbox.select(".linear-combo").set("visible", val);
    });
    doAxes.onFinishChange(function(val) {
        mathbox.select(".axes").set("visible", val);
    });

    var vector1 = [5, 3, -2];
    var vector2 = [3, -4, 1];
    var vectors = [vector1, vector2];
    var ortho1 = new THREE.Vector3(vector1[0],vector1[1],vector1[2]);
    var ortho2 = new THREE.Vector3(vector2[0],vector2[1],vector2[2]);
    var ortho = [ortho1, ortho2];
    this.orthogonalize(ortho1, ortho2);
    var color1 = [1, .3, 1, 1];
    var color2 = [0, 1, 0, 1];
    var colors = [color1, color2];
    var tColor1 = new THREE.Color(color1[0], color1[1], color1[2]);
    var tColor2 = new THREE.Color(color2[0], color2[1], color2[2]);

    this.labeledVectors(vectors, colors, ['v1', 'v2'], {
        zeroPoints: true,
    });
    mathbox.select("#vectors-drawn").set('zIndex', 2);
    mathbox.select("#vector-labels").set('zIndex', 2);
    mathbox.select("#zero-points").set('zIndex', 3);

    this.view
    // linear combination
        .matrix({
            channels: 3,
            width:    2,
            height:   2,
            expr: function(emit, i, j) {
                var vec1 = i == 0 ? [0, 0, 0] : vector1;
                var vec2 = j == 0 ? [0, 0, 0] : vector2;
                emit(vec1[0]*params.a + vec2[0]*params.b,
                     vec1[1]*params.a + vec2[1]*params.b,
                     vec1[2]*params.a + vec2[2]*params.b);
            }
        })
        .surface({
            classes: ["linear-combo"],
            color:   "white",
            opacity: 0.75,
            lineX:   true,
            lineY:   true,
            fill:    false,
            width:   3,
            zIndex:  1,
        })
        .array({
            channels: 3,
            width:    1,
            expr: function(emit) {
                emit(vector1[0]*params.a + vector2[0]*params.b,
                     vector1[1]*params.a + vector2[1]*params.b,
                     vector1[2]*params.a + vector2[2]*params.b);
            },
        })
        .point({
            classes: ["linear-combo"],
            color:  "rgb(0,255,255)",
            zIndex: 2,
            size:   15,
        })
        .text({
            live:  true,
            width: 1,
            expr: function(emit) {
                var b = Math.abs(params.b);
                var add = params.b >= 0 ? "+" : "-";
                emit(params.a.toFixed(2) + "v1" + add + b.toFixed(2) + "v2")
            },
        })
        .label({
            classes: ["linear-combo"],
            outline: 0,
            color:  "rgb(0,255,255)",
            offset:  [0, 25],
            size:    15,
            zIndex:  3,
        })
    ;

    mathbox.select(".linear-combo").set("visible", params['Show a.v1 + b.v2']);

    var clipped = this.clipCube({
        drawCube:       true,
        wireframeColor: new THREE.Color(.75, .75, .75)
    });

    clipped
        .matrix({
            channels: 3,
            live:     true,
            width:    2,
            height:   2,
            expr: function (emit, i, j) {
                if(i == 0) i = -1;
                if(j == 0) j = -1;
                i *= 30; j *= 30;
                emit(ortho1.x * i + ortho2.x * j,
                     ortho1.y * i + ortho2.y * j,
                     ortho1.z * i + ortho2.z * j);
            }
        })
    ;
    var surface = clipped
        .surface({
            color:   "rgb(128,0,0)",
            opacity: 0.5,
            stroke:  "solid",
            lineX:   true,
            lineY:   true,
            width:   5,
        })
    ;

    var snap_threshold = 1.0;
    var spanType;

    var onDrag = (function() {
        var otherVec = new THREE.Vector3();
        var projection = new THREE.Vector3();
        var diff = new THREE.Vector3();

        return function(vec) {
            var other   = vectors[1-draggable.dragging];
            var otherIsZero = (other[0] == 0 && other[1] == 0 && other[2] == 0);

            if(vec.dot(vec) < snap_threshold) {
                // active vector is zero
                vec.set(0,0,0);
                ortho1.set(0, 0, 0);
                if(otherIsZero) {
                    ortho2.set(0, 0, 0);
                    if(paramsQS.indep)
                        spanType.innerText = "linearly dependent";
                    else
                        spanType.innerText = "point";
                }
                else {
                    ortho2.set.apply(ortho2, other).normalize();
                    if(paramsQS.indep)
                        spanType.innerText = "linearly dependent";
                    else
                        spanType.innerText = "line";
                }
                surface.set('opacity', 1.0);
                self.zeroPoints.set('visible', true);
                return;
            }

            if(otherIsZero) {
                // active vector is nonzero but other vector is zero
                ortho1.copy(vec).normalize();
                ortho2.set(0, 0, 0);
                surface.set('opacity', 1.0);
                if(paramsQS.indep)
                    spanType.innerText = "linearly dependent";
                else
                    spanType.innerText = "line";
                self.zeroPoints.set('visible', true);
                return;
            }

            // both vectors are nonzero
            otherVec.set.apply(otherVec, other);
            projection.copy(vec).projectOnVector(otherVec);
            diff.copy(projection).sub(vec);

            if(diff.dot(diff) < snap_threshold) {
                vec.copy(projection);
                ortho1.copy(otherVec).normalize();
                ortho2.copy(ortho1);
                surface.set('opacity', 1.0);
                if(paramsQS.indep)
                    spanType.innerText = "linearly dependent";
                else
                    spanType.innerText = "line";
            } else {
                ortho1.copy(otherVec);
                ortho2.copy(vec);
                self.orthogonalize(ortho1, ortho2);
                surface.set('opacity', 0.5);
                if(paramsQS.indep)
                    spanType.innerText = "linearly independent";
                else
                    spanType.innerText = "plane";
            }
            self.zeroPoints.set('visible', false);
        };
    })();

    // Make the vectors draggable
    var draggable = new Draggable({
        view:   this.view,
        points: vectors,
        size:   30,
        hiliteColor: [0, 1, 1, .75],
        onDrag: onDrag,
    });

    if(paramsQS.indep)
        this.label.innerHTML = "The vectors " + katex.renderToString(
            "\\{\\color{#" + tColor1.getHexString() + "}{v_1},"
                + "\\color{#" + tColor2.getHexString() + "}{v_2}\\}")
            + ' are <strong><span id="span-type">linearly independent</span></strong>'
            + "<br><br>[Drag the vector heads with the mouse to move them]";
    else
        this.label.innerHTML = "The span of " + katex.renderToString(
            "\\{\\color{#" + tColor1.getHexString() + "}{v_1},"
                + "\\color{#" + tColor2.getHexString() + "}{v_2}\\}")
            + ' is a <strong><span id="span-type">plane</span></strong>'
            + "<br><br>[Drag the vector heads with the mouse to move them]";
    spanType = document.getElementById("span-type");
});

