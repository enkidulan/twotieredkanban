m = angular.module("kb.util", ["ngMaterial"])

class Menu
  constructor: () ->
    @labels = []
    @functions = []

  add: (label, func) =>
    @labels.push(label)
    @functions[label] = func

  use: (label) => @injector.invoke(@functions[label])

m.provider('kbMenu', () ->
  menus = {}
  {
    add: (name, label, func) ->
      if not menus[name]?
        menus[name] = new Menu
      menus[name].add(label, func)
 
    $get: ($injector) ->
      for _, menu of menus
        menu.injector = $injector
      menus
  }
  )

m.directive('kbReturn', () ->
  restrict: 'A'
  scope: { result: '=kbReturn', keydown: '=' }
  link: (scope) ->
    scope.keydown = (event) ->
      key = event.which or event.keyCode
      if key == 13
        scope.result(true)
      if key == 27
        scope.result(false)
  )

m.factory('kbDialog', ($mdDialog, $injector) ->
  show: (props) ->
    $mdDialog.show(
      controller: ($scope, $mdDialog) ->
        for name, val of props.scope
          $scope[name] = val
        $scope.cancel = $mdDialog.cancel
        $scope.hide = $mdDialog.hide
        if props.controller?
          props.controller($scope)
      targetEvent: props.targetEvent
      parent: props.parent
      template: """
        <md-dialog aria-label="{{ title }}">
          <h4 ng-if="title">{{ title }}</h4>
          <md-dialog-content>#{ props.template }</md-dialog-content>
          <div class="md-actions" layout="row" layout-align="end center">
            <md-button ng-click="cancel()">
              {{ cancel_action || 'Cancel' }}
            </md-button>
            <md-button ng-click="hide(result)">
              {{ action }}
            </md-button>
          </div>
        </md-dialog>
        """
      )
  )

m.filter('breakify', ->
  (text) -> text.replace("\n\n", "<br><br>")
  )
