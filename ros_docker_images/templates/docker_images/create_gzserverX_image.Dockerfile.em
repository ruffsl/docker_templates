@(TEMPLATE(
    'snippet/add_generated_comment.Dockerfile.em',
    user_name=user_name,
    tag_name=tag_name,
    source_template_name=template_name,
    now_str=now_str,
))@
@(TEMPLATE(
    'snippet/from_base_image.Dockerfile.em',
    template_packages=template_packages,
    os_name=os_name,
    os_code_name=os_code_name,
    arch=arch,
    base_image=base_image,
))@
MAINTAINER Nate Koenig nkoenig@@osrfoundation.org
@[if 'packages' in locals()]@
@[if packages]@

# install packages
RUN apt-get update && apt-get install -q -y \
    @(' \\\n    '.join(packages))@  \
    && rm -rf /var/lib/apt/lists/*

    @[end if]@
@[end if]@
@[if 'gazebo_packages' in locals()]@
@[if gazebo_packages]@
# setup keys
RUN apt-key adv --keyserver ha.pool.sks-keyservers.net --recv-keys D2486D2DD83DB69272AFE98867170598AF249743

# setup sources.list
RUN echo "deb http://packages.osrfoundation.org/gazebo/ubuntu `lsb_release -cs` main" > /etc/apt/sources.list.d/gazebo-latest.list

# install gazebo packages
RUN apt-get update && apt-get install -q -y \
    @(' \\\n    '.join(gazebo_packages))@  \
    && rm -rf /var/lib/apt/lists/*

@[end if]@
@[end if]@
@[if 'pip_install' in locals()]@
@[if pip_install]@

# install python packages
RUN pip install \
    @(' \\\n    '.join(pip_install))@

@[end if]@
@[end if]@

# clone source
ENV WS @(ws)
RUN mkdir -p @(ws)/src
@(TEMPLATE(
    'snippet/clone_sources.Dockerfile.em',
    sources=sources,
    ws=ws,
))@

# build source
RUN cd @(ws) \
    && catkin init \
    && catkin build \
    -vi \
    --cmake-args \
    @(' \\\n    '.join(cmake_args))@


# setup environment
EXPOSE 11345

@[if 'entrypoint_name' in locals()]@
@[if entrypoint_name]@
@{
entrypoint_file = entrypoint_name.split('/')[-1]
}@
# setup entrypoint
COPY ./@entrypoint_file /

ENTRYPOINT ["/@entrypoint_file"]
@[end if]@
@[end if]@
@{
cmds = [
'gzserver',
]
}@
CMD ["@(' && '.join(cmds))"]
