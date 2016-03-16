###
# Copyright (C) 2014-2016 Taiga Agile LLC <taiga@taiga.io>
#
# This program is free software: you can redistribute it and/or modify
# it under the terms of the GNU Affero General Public License as
# published by the Free Software Foundation, either version 3 of the
# License, or (at your option) any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
# GNU Affero General Public License for more details.
#
# You should have received a copy of the GNU Affero General Public License
# along with this program. If not, see <http://www.gnu.org/licenses/>.
#
# File: transfer-project.directive.coffee
###

TransferProjectDirective = ($routeParams, $location, navUrls, authService, currentUserService, projectsService) ->
    link = (scope, el, attrs, ctrl) ->
        projectId = ctrl.project.get("id")
        token = $routeParams.token
        isPrivate = ctrl.project.get("is_private")
        authService.refresh().then () ->
            scope.vm.canBeOwnedByUser = currentUserService.canOwnProject(ctrl.project)
            scope.vm.token = token
            currentUser = currentUserService.getUser().toJS()
            console.log currentUser.max_members_private_projects
            scope.vm.maxPrivateProjects = currentUser.max_private_projects
            # scope.vm.maxPublicProjects = currentUser.max_public_projects
            scope.vm.maxMembers = currentUser.max_members_private_projects

        projectsService.transferValidateToken(projectId, token).error (data, status) ->
            $location.path(navUrls.resolve("not-found"))

    return {
        controller: "Project"
        controllerAs: "vm"
        link: link
    }

TransferProjectDirective.$inject = [
    "$routeParams",
    "$location",
    "$tgNavUrls",
    "$tgAuth",
    "tgCurrentUserService",
    "tgProjectsService"
]

angular.module('taigaProjects').directive('tgTransferProject', TransferProjectDirective)
