# Copyright (c) Stanford University, The Regents of the University of
#               California, and others.
#
# All Rights Reserved.
#
# See Copyright-SimVascular.txt for additional details.
#
# Permission is hereby granted, free of charge, to any person obtaining
# a copy of this software and associated documentation files (the
# "Software"), to deal in the Software without restriction, including
# without limitation the rights to use, copy, modify, merge, publish,
# distribute, sublicense, and/or sell copies of the Software, and to
# permit persons to whom the Software is furnished to do so, subject
# to the following conditions:
#
# The above copyright notice and this permission notice shall be included
# in all copies or substantial portions of the Software.
#
# THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS
# IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED
# TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A
# PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT OWNER
# OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL,
# EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO,
# PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR
# PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF
# LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING
# NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
# SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.

proc vis_splineWidgetAdd [list ren input name EnableEvent StartInteractionEvent \
                              InteractionEvent EndInteractionEvent] {

  set interactor "vis_splineWidget_interactor_$ren\_$name"
  # create interactive cursor
  catch {$interactor Delete}
  vtkSplineWidget $interactor
  $interactor SetInputData $input
  $interactor PlaceWidget
  [$interactor GetHandleProperty] SetOpacity 0.33

  set iren genericInteractor_$ren

  # Associate the point widget with the interactor
  $interactor SetInteractor $iren
  $interactor EnabledOff
  $interactor AddObserver EnableEvent $EnableEvent
  $interactor AddObserver StartInteractionEvent $StartInteractionEvent
  $interactor AddObserver InteractionEvent $InteractionEvent
  $interactor AddObserver EndInteractionEvent $EndInteractionEvent

  global gRen3d
  global gRen3dCopies
  if {$ren == $gRen3d} {
    foreach ren $gRen3dCopies {
      set interactor "vis_splineWidget_interactor_$ren\_$name"
      # create interactive cursor
      catch {$interactor Delete}
      vtkSplineWidget $interactor
      $interactor SetInputData $input
      $interactor PlaceWidget
      [$interactor GetHandleProperty] SetOpacity 0.33

      set iren genericInteractor_$ren

      # Associate the point widget with the interactor
      $interactor SetInteractor $iren
      $interactor AddObserver EnableEvent $EnableEvent
      $interactor AddObserver StartInteractionEvent $StartInteractionEvent
      $interactor AddObserver InteractionEvent $InteractionEvent
      $interactor AddObserver EndInteractionEvent $EndInteractionEvent
    }
  }
}

proc vis_splineWidgetRm {ren name} {
  set interactor "vis_splineWidget_interactor_$ren\_$name"

  vis_splineWidgetOff $ren $name

  $interactor Delete
  global gRen3d
  global gRen3dCopies
  if {$ren == $gRen3d} {
    foreach ren $gRen3dCopies {
      set interactor "vis_splineWidget_interactor_$ren\_$name"
      $interactor Delete
    }
  }
}

proc vis_splineWidgetOn {ren name} {
  set interactor "vis_splineWidget_interactor_$ren\_$name"
  $interactor EnabledOn
  # having problems getting spline to display correctly,
  # do a dummy update of handle 0 to update display
  set dummy [$interactor GetHandlePosition 0]
  eval $interactor SetHandlePosition 0 $dummy
  vis_render $ren
  global gRen3d
  global gRen3dCopies
  if {$ren == $gRen3d} {
    foreach ren $gRen3dCopies {
      set interactor "vis_splineWidget_interactor_$ren\_$name"
      $interactor EnabledOn
      # having problems getting spline to display correctly,
      # do a dummy update of handle 0 to update display
      set dummy [$interactor GetHandlePosition 0]
      eval $interactor SetHandlePosition 0 $dummy
      vis_render $ren
    }
  }
}

proc vis_splineWidgetOff {ren name} {
  set interactor "vis_splineWidget_interactor_$ren\_$name"
  $interactor EnabledOff
  global gRen3d
  global gRen3dCopies
  if {$ren == $gRen3d} {
    foreach ren $gRen3dCopies {
      set interactor "vis_splineWidget_interactor_$ren\_$name"
      $interactor EnabledOff
    }
  }
}


proc vis_splineWidgetSetPts {ren name pd numHandles} {

  set interactor "vis_splineWidget_interactor_$ren\_$name"

  set pts {}
  geom_getPts $pd pts
  set numPts [llength $pts]

  set splineX vis_splineWidgetSetPts-splineX
  set splineY vis_splineWidgetSetPts-splineY
  set splineZ vis_splineWidgetSetPts-splineZ
  catch {$splineX Delete}
  catch {$splineY Delete}
  catch {$splineZ Delete}
  vtkCardinalSpline $splineX
  vtkCardinalSpline $splineY
  vtkCardinalSpline $splineZ
  $splineX ClosedOff
  $splineY ClosedOff
  $splineZ ClosedOff

  set ptid 0
  foreach i $pts {
    $splineX AddPoint $ptid [lindex $i 0]
    $splineY AddPoint $ptid [lindex $i 1]
    $splineZ AddPoint $ptid [lindex $i 2]
    incr ptid
  }
  $splineX Compute
  $splineY Compute
  $splineZ Compute

  $interactor SetNumberOfHandles $numHandles

  set pts {}
  set numPts $numHandles
  set dx [expr double($ptid)/($numHandles-1)]
  set ptid 0
  for {set i 0} {$i < $numHandles} {incr i} {
    set d [expr $dx * $i]
    $interactor SetHandlePosition $ptid [$splineX Evaluate $d] \
                                        [$splineY Evaluate $d] \
                                        [$splineZ Evaluate $d]
    lappend pts [list [$splineX Evaluate $d] \
                      [$splineY Evaluate $d] \
                      [$splineZ Evaluate $d]]
    incr ptid
  }
  $splineX Delete
  $splineY Delete
  $splineZ Delete

  global gRen3d
  global gRen3dCopies
  if {$ren == $gRen3d} {
    foreach ren $gRen3dCopies {
      set interactor "vis_splineWidget_interactor_$ren\_$name"
      $interactor SetNumberOfHandles $numPts
      set ptid 0
      foreach i $pts {
      $interactor SetHandlePosition $ptid [lindex $i 0] \
                                          [lindex $i 1] \
                                          [lindex $i 2]
      incr ptid
      }
    }
  }
}


proc vis_splineWidgetUpdatePts {ren name pts} {

  set interactor "vis_splineWidget_interactor_$ren\_$name"

  set numPts [llength $pts]

  set ptid 0
  foreach i $pts {
    $interactor SetHandlePosition $ptid [lindex $i 0] \
                                        [lindex $i 1] \
                                        [lindex $i 2]
    incr ptid
  }

  global gRen3d
  global gRen3dCopies
  if {$ren == $gRen3d} {
    foreach ren $gRen3dCopies {
      set interactor "vis_splineWidget_interactor_$ren\_$name"
      set ptid 0
      foreach i $pts {
      $interactor SetHandlePosition $ptid [lindex $i 0] \
                                          [lindex $i 1] \
                                          [lindex $i 2]
      incr ptid
      }
    }
  }

}


proc vis_splineWidgetGetPts {ren name} {
  set interactor "vis_splineWidget_interactor_$ren\_$name"
  set pts {}
  set numPts [$interactor GetNumberOfHandles]
  for {set i 0} {$i < $numPts} {incr i} {
    lappend pts [$interactor GetHandlePosition $i]
  }
  return $pts
}


proc vis_splineWidgetSetNumHandles {ren name num} {
  set interactor "vis_splineWidget_interactor_$ren\_$name"
  $interactor SetNumberOfHandles $num
  global gRen3d
  global gRen3dCopies
  if {$ren == $gRen3d} {
    foreach ren $gRen3dCopies {
      set interactor "vis_splineWidget_interactor_$ren\_$name"
      $interactor SetNumberOfHandles $num
    }
  }
}


proc vis_splineWidgetGetNumHandles {ren name} {
  set interactor "vis_splineWidget_interactor_$ren\_$name"
  return [$interactor GetNumberOfHandles]
}



