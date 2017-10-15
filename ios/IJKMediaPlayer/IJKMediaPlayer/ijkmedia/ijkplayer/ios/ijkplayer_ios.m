/*
 * ijkplayer_ios.c
 *
 * Copyright (c) 2013 Zhang Rui <bbcallen@gmail.com>
 *
 * This file is part of ijkPlayer.
 *
 * ijkPlayer is free software; you can redistribute it and/or
 * modify it under the terms of the GNU Lesser General Public
 * License as published by the Free Software Foundation; either
 * version 2.1 of the License, or (at your option) any later version.
 *
 * ijkPlayer is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
 * Lesser General Public License for more details.
 *
 * You should have received a copy of the GNU Lesser General Public
 * License along with ijkPlayer; if not, write to the Free Software
 * Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA 02110-1301 USA
 */

#import "ijkplayer_ios.h"

#import "ijksdl/ios/ijksdl_ios.h"

#include <stdio.h>
#include <assert.h>
#include "ijkplayer/ff_fferror.h"
#include "ijkplayer/ff_ffplay.h"
#include "ijkplayer/ijkplayer_internal.h"
#include "ijkplayer/pipeline/ffpipeline_ffplay.h"
#include "pipeline/ffpipeline_ios.h"

IjkMediaPlayer *ijkmp_ios_create(int (*msg_loop)(void*))
{
//创建IJKMediaPlayer对象
    IjkMediaPlayer *mp = ijkmp_create(msg_loop);
    if (!mp)
        goto fail;
    
//创建图像渲染对象SDL_Vout
    mp->ffplayer->vout = SDL_VoutIos_CreateForGLES2();
    if (!mp->ffplayer->vout)
        goto fail;
    
//创建平台相关的IJKFF_Pipeline对象，包括视频解码以及音频输出部分
    mp->ffplayer->pipeline = ffpipeline_create_from_ios(mp->ffplayer);
    if (!mp->ffplayer->pipeline)
        goto fail;

//    简单来说，就是创建播放器对象，完成音视频解码、渲染的准备工作
    return mp;

fail:
    ijkmp_dec_ref_p(&mp);
    return NULL;
}

void ijkmp_ios_set_glview_l(IjkMediaPlayer *mp, IJKSDLGLView *glView)
{
    assert(mp);
    assert(mp->ffplayer);
    assert(mp->ffplayer->vout);

    SDL_VoutIos_SetGLView(mp->ffplayer->vout, glView);
}

void ijkmp_ios_set_glview(IjkMediaPlayer *mp, IJKSDLGLView *glView)
{
    assert(mp);
    MPTRACE("ijkmp_ios_set_view(glView=%p)\n", (void*)glView);
    pthread_mutex_lock(&mp->mutex);
    ijkmp_ios_set_glview_l(mp, glView);
    pthread_mutex_unlock(&mp->mutex);
    MPTRACE("ijkmp_ios_set_view(glView=%p)=void\n", (void*)glView);
}

bool ijkmp_ios_is_videotoolbox_open_l(IjkMediaPlayer *mp)
{
    assert(mp);
    assert(mp->ffplayer);

    return false;
}

bool ijkmp_ios_is_videotoolbox_open(IjkMediaPlayer *mp)
{
    assert(mp);
    MPTRACE("%s()\n", __func__);
    pthread_mutex_lock(&mp->mutex);
    bool ret = ijkmp_ios_is_videotoolbox_open_l(mp);
    pthread_mutex_unlock(&mp->mutex);
    MPTRACE("%s()=%d\n", __func__, ret ? 1 : 0);
    return ret;
}
