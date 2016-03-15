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
# File: project.controller.coffee
###

class ProjectController
    @.$inject = [
        "$routeParams",
        "tgAppMetaService",
        "$location",
        "$tgConfirm",
        "$tgNavUrls",
        "$tgAuth",
        "$translate",
        "tgProjectService"
    ]

    constructor: (@routeParams, @appMetaService, @location, @confirmService, @navUrls, @auth, @translate, @projectService) ->
        projectSlug = @routeParams.pslug
        @.user = @auth.userData

        taiga.defineImmutableProperty @, "project", () => return @projectService.project
        taiga.defineImmutableProperty @, "members", () => return @projectService.activeMembers

        @appMetaService.setfn @._setMeta.bind(this)

    transferAccept: (token, reason) ->
        @projectService.transferAccept(token, reason).success () =>
            newUrl = @navUrls.resolve("project-admin-project-profile-details", {
                project: @project.get("slug")
            })
            @location.path(newUrl)
            #TODO: this text isn't shown
            @confirmService.notify("success", @translate.instant("ADMIN.PROJECT_TRANSFER.ACCEPTED_PROJECT_OWNERNSHIP"), '', 5000)

    transferReject: (token, reason) ->
        @projectService.transferAccept(token, reason).success () =>
            newUrl = @navUrls.resolve("project-admin-project-profile-details", {
                project: @project.get("slug")
            })
            @location.path(newUrl)
            #TODO: this text isn't shown
            @confirmService.notify("success", @translate.instant("ADMIN.PROJECT_TRANSFER.REJECTED_PROJECT_OWNERNSHIP"), '', 5000)

    _setMeta: (project)->
        return null if !@.project

        metas = {}

        ctx = {projectName: @.project.get("name")}

        metas.title = @translate.instant("PROJECT.PAGE_TITLE", ctx)
        metas.description = @.project.get("description")

        return metas

angular.module("taigaProjects").controller("Project", ProjectController)
