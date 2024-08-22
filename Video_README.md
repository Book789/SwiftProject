# 视频相关知识

ffmpeg -i input.mp4 -c:v libx265 -vtag hvc1 -vf scale=1920:1080 -crf 20 -c:a copy output.mp4
-i输入文件名或文件路径

-c:v libx265 -vtag hvc1选择压缩。默认值为libx264

-vf scale=1920:1080指定输出分辨率

-c:a copy原样复制音频，不进行任何压缩

-preset slow要求压缩算法花费更多的时间并寻找更多的压缩区域。默认值为medium。其他选项包括faster、fast、medium、slow、slower

-crf 20压缩质量

 -crf 0高质量、低压缩、大文件-crf 23默认-crf 51低质量、高压缩、小文件



ffmpeg -i ankle_activation_video.mp4 -c:v libx265 -x265-params crf=20 ankle_activation_video1.mp4
ffmpeg -i ankle_activation_video1.mp4 -c:v copy -tag:v hvc1 -c:a copy ankle_activation_video2.mp4
