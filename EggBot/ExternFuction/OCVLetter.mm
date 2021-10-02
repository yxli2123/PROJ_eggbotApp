//
//  OCVLetter.m
//  EggBot
//
//  Created by Zijie Zhou on 2019/12/2.
//  Copyright © 2019 Yixiao Li. All rights reserved.
//

#include "opencv2/highgui.hpp"
#include "opencv2/imgproc.hpp"
#include "opencv2/highgui/highgui.hpp"
#include "opencv2/core/core.hpp"
#include <stdio.h>
#include <stdlib.h>
#include "opencv2/imgcodecs/ios.h"
#include "OCVLetter.h"
///系统参数变量
#define PI 3.1415927
#define PAINTING 800 //绘画行列
#define Edge_width 3 //边缘宽度
#define LEVEL 50  //提取轮廓参数，颜色大于其则被视为轮廓 (0<***<=255)
#define SPACE 1  //提取轮廓参数，间隔输出点的步长 ***>=1
#define MinMotorValue (0.9*100/PAINTING) //电机最小转动分度
#define Egg_Length 6
#define Egg_Diameter 4.5 //鸡蛋参数
#define SIZE 10000

//数值范围0~255,负数范围0~124,零为125,正数范围126~250,画笔抬起253，落下254，结束255！！！
struct MatResult {
    cv::Mat Preview;  //预览图
    unsigned char X[SIZE], Y[SIZE];  //x,y的移动数据
    int X_Size = 0, Y_Size = 0;  //x,y个数
};

std::vector<std::vector<cv::Point> > GetContours(cv::Mat canny_output);  //从线条中获得轮廓
std::vector<std::vector<cv::Point> > Contour_Process(std::vector<std::vector<cv::Point> > contours, double AddCoef);   //轮廓处理函数。将轮廓剪裁，变形
MatResult Contour_Putout(std::vector<std::vector<cv::Point> > contours_c);   //输出轮廓
cv::Mat TextCanny(const char* src, int thresh, int Type);
MatResult ImgProcess(cv::Mat canny_output, double AddCoef);


cv::Mat TextCanny(const char* Text, int thresh, int Type) {
    int fontFace = 1;
    switch (Type)
    {
    case 1:
        fontFace = cv::QT_FONT_BLACK;
        break;
    case 2:
        fontFace = cv::FONT_HERSHEY_DUPLEX;
        break;
    case 3:
        fontFace = cv::FONT_HERSHEY_PLAIN;
        break;
    case 4:
        fontFace = cv::FONT_HERSHEY_SCRIPT_SIMPLEX;
        break;
    case 5:
        fontFace = cv::FONT_HERSHEY_SIMPLEX;
        break;
    case 6:
        fontFace = cv::FONT_HERSHEY_TRIPLEX;
        break;
    case 7:
        fontFace = cv::FONT_ITALIC;
        break;
    case 8:
        fontFace = cv::QT_FONT_NORMAL;
        break;
    default:
        break;
    }
    cv::Mat src(400, 2000, CV_8UC3, cv::Scalar(0, 0, 0));
    cv::putText(src, Text, cv::Point(50, 250), fontFace, 8, cv::Scalar(255, 255, 255), 9);
/*
    cv::namedWindow("Text",CV_WND_PROP_AUTOSIZE);
    cv::imshow("Text",src);
    cv::waitKey(0);
*/
    cv::Mat src_gray;
    cv::Mat canny_output;
    cvtColor(src, src_gray, cv::COLOR_BGR2GRAY);
    cv::blur(src_gray, src_gray, cv::Size(3, 3));
    cv::Canny(src_gray, canny_output, thresh, thresh * 2, 3); // 用Canny算子检测边缘
    return canny_output;
}
MatResult ImgProcess(cv::Mat canny_output, double AddCoef) {
    return Contour_Putout(Contour_Process(GetContours(canny_output), AddCoef));  //寻找轮廓 处理轮廓 输出轮廓
}
cv::Point FindPoint(cv::Mat Copy, cv::Point ContourPoint){
    int m, n, k;
    bool flag;
    do
    {
        for (m = -1; m <= 1; m++) //将点四周抹除
            for (n = -1; n <= 1; n++)
                Copy.at<uchar>(ContourPoint.y + m, ContourPoint.x + n) = 0;

        flag = false;//再顺时针向四周寻点
        for (k = -2; k < 2; k++)
            if (Copy.at<uchar>(ContourPoint.y - 2, ContourPoint.x + k) > LEVEL)
            {
                flag = true; //标记寻到点
                ContourPoint.y = ContourPoint.y - 2;
                ContourPoint.x = ContourPoint.x + k;
                break;
            }
        if (flag == false) //若未寻到点
            for (k = -2; k < 2; k++)
                if (Copy.at<uchar>(ContourPoint.y + k, ContourPoint.x + 2) > LEVEL)
                {
                    flag = true;
                    ContourPoint.y = ContourPoint.y + k;
                    ContourPoint.x = ContourPoint.x + 2;
                    break;
                }
        if (flag == false)
            for (k = 2; k > -2; k--)
                if (Copy.at<uchar>(ContourPoint.y + 2, ContourPoint.x + k) > LEVEL)
                {
                    flag = true;
                    ContourPoint.y = ContourPoint.y + 2;
                    ContourPoint.x = ContourPoint.x + k;
                    break;
                }
        if (flag == false)
            for (k = 2; k > -2; k--)
                if (Copy.at<uchar>(ContourPoint.y + k, ContourPoint.x - 2) > LEVEL)
                {
                    flag = true;
                    ContourPoint.y = ContourPoint.y + k;
                    ContourPoint.x = ContourPoint.x - 2;
                    break;
                }
    } while (flag);//若最终未寻到点，则退出
    return ContourPoint;
}
std::vector<std::vector<cv::Point> > GetContours(cv::Mat canny_output){
    int i, j, m, n, k;
    cv::Mat Copy;
    cv::Point ContourPoint;
    std::vector<cv::Point> ContourVector;
    std::vector<std::vector<cv::Point> > contours; //保存原始轮廓点
    bool flag_contour;

    //剔除边缘
    for (i = 0; i < canny_output.rows; i++)
    {
        canny_output.at<uchar>(i, 0) = canny_output.at<uchar>(i, 1) = canny_output.at<uchar>(i, 2) = canny_output.at<uchar>(i, canny_output.cols - 1)
            = canny_output.at<uchar>(i, canny_output.cols - 2) = canny_output.at<uchar>(i, canny_output.cols - 3) = 0;
    }
    for (j = 0; j < canny_output.cols; j++)
    {
        canny_output.at<uchar>(0, j) = canny_output.at<uchar>(1, j) = canny_output.at<uchar>(2, j) = canny_output.at<uchar>(canny_output.rows - 1, j)
            = canny_output.at<uchar>(canny_output.rows - 2, j) = canny_output.at<uchar>(canny_output.rows - 3, j) = 0;
    }

    do {
        flag_contour = false;
        for (i = 2; i < canny_output.rows - 2 && !flag_contour; i++)
        {
            for (j = 2; j < canny_output.cols - 2 && !flag_contour; j++)
            {
                if (canny_output.at<uchar>(i, j) > LEVEL) //遇到边缘点
                {
                    bool flag;
                    ContourPoint.y = i;
                    ContourPoint.x = j;
                    canny_output.copyTo(Copy); //复制
                    ContourPoint = FindPoint(Copy, ContourPoint);

                    do
                    {
                        ContourVector.push_back(ContourPoint); //点入向量
                        for (m = -1; m <= 1; m++) //将点四周抹除
                            for (n = -1; n <= 1; n++)
                                canny_output.at<uchar>(ContourPoint.y + m, ContourPoint.x + n) = 0;

                        flag = false;//再顺时针向四周寻点
                        for (k = -2; k < 2; k++)
                            if (canny_output.at<uchar>(ContourPoint.y - 2, ContourPoint.x + k) > LEVEL)
                            {
                                flag = true; //标记寻到点
                                ContourPoint.y = ContourPoint.y - 2;
                                ContourPoint.x = ContourPoint.x + k;
                                break;
                            }
                        if (flag == false) //若未寻到点
                            for (k = -2; k < 2; k++)
                                if (canny_output.at<uchar>(ContourPoint.y + k, ContourPoint.x + 2) > LEVEL)
                                {
                                    flag = true;
                                    ContourPoint.y = ContourPoint.y + k;
                                    ContourPoint.x = ContourPoint.x + 2;
                                    break;
                                }
                        if (flag == false)
                            for (k = 2; k > -2; k--)
                                if (canny_output.at<uchar>(ContourPoint.y + 2, ContourPoint.x + k) > LEVEL)
                                {
                                    flag = true;
                                    ContourPoint.y = ContourPoint.y + 2;
                                    ContourPoint.x = ContourPoint.x + k;
                                    break;
                                }
                        if (flag == false)
                            for (k = 2; k > -2; k--)
                                if (canny_output.at<uchar>(ContourPoint.y + k, ContourPoint.x - 2) > LEVEL)
                                {
                                    flag = true;
                                    ContourPoint.y = ContourPoint.y + k;
                                    ContourPoint.x = ContourPoint.x - 2;
                                    break;
                                }
                    } while (flag);//若最终未寻到点，则退出
                    contours.push_back(ContourVector);
                    ContourVector.clear();
                    flag_contour = true;
                }
            }
        }
    } while (flag_contour);
    return contours;
}
std::vector<std::vector<cv::Point> > Contour_Process(std::vector<std::vector<cv::Point> > contours, double AddCoef){
    int i, j; //遍历计数
    double coef; //系数

    std::vector<cv::Point> vector_p;
    std::vector<std::vector<cv::Point> > contours_s; //保存第一步处理的轮廓点
    std::vector<std::vector<cv::Point> > contours_c;

    ////图像剪裁与放缩

    //图像剪裁
    int min_row = 9999, max_row = 0, min_col = 9999, max_col = 0; //剪裁用参数

    cv::Point P, Q;

    for (i = 0; i < contours.size(); i++) //获取最值
    {
        for (j = 0; j < contours[i].size(); j++)
        {
            if (contours[i][j].x < min_row) min_row = contours[i][j].x;
            if (contours[i][j].x > max_row) max_row = contours[i][j].x;
            if (contours[i][j].y < min_col) min_col = contours[i][j].y;
            if (contours[i][j].y > max_col) max_col = contours[i][j].y;
        }
    }
    coef = (double)(PAINTING - 2 * Edge_width) / (double)((max_col - min_col) > (max_row - min_row) ? (max_col - min_col) : (max_row - min_row)); //计算比例系数
    for (i = 0; i < contours.size(); i++) //剪裁点
    {
        for (j = 0; j < contours[i].size(); j++)
        {
            P.x = (int)((contours[i][j].x - min_row)*coef + (PAINTING - (max_row - min_row)*coef) / 2); //坐标变换
            P.y = (int)((contours[i][j].y - min_col)*coef + (PAINTING - (max_col - min_col)*coef) / 2);
            if (j == 0 || (P.x != Q.x || P.y != Q.y)) //除去重复点
                vector_p.push_back(P);
            Q.x = P.x;
            Q.y = P.y;
        }
        if (vector_p.size() > PAINTING / 30)
            contours_s.push_back(vector_p);
        vector_p.clear(); //释放内存
    }

    ///图像变换
    double c1, c2, Angle;
    c1 = AddCoef * (double)Egg_Diameter / (double)Egg_Length;

    for (i = 0; i < contours_s.size(); i++)
    {
        for (j = 0; j < contours_s[i].size(); j++)
        {
            Angle = (contours_s[i][j].y - PAINTING / 2)*MinMotorValue*PI / 180;  //获取当前角度
            c2 = c1 * c1*sin(Angle)*sin(Angle) + cos(Angle)*cos(Angle);
            coef = pow(c2, 0.5) / (cos(Angle)*pow(c1*c1 + 1, 0.5));
            P.x = (int)((contours_s[i][j].x - PAINTING / 2)*coef + PAINTING / 2); //坐标变换
            P.y = contours_s[i][j].y;
            if (j == 0 || (P.x != Q.x || P.y != Q.y)) //除去重复点
                vector_p.push_back(P);
            Q.x = P.x;
            Q.y = P.y;
        }
        if ((P.x - vector_p[0].x <= PAINTING / 50 && P.x - vector_p[0].x >= -PAINTING / 50) && (P.y - vector_p[0].y <= PAINTING / 50 && P.y - vector_p[0].y >= -PAINTING / 50))
            vector_p[vector_p.size() - 1] = vector_p[0];
        if (vector_p.size() > 3)
            contours_c.push_back(vector_p);
        vector_p.clear(); //释放内存
    }
    return contours_c;
}
MatResult Contour_Putout(std::vector<std::vector<cv::Point> > contours_c){
    int i, j, k;
    int tooLong_x, tooLong_y;
    MatResult M;
    ///输出测试
    //画笔抬起362,落下-362,画笔抬起253，落下254，结束255
    int pre_x = PAINTING / 2, pre_y = PAINTING / 2;
    k = 0;
    for (i = 0; i < contours_c.size(); i++) //显示点
    {
        tooLong_x = contours_c[i][0].x - pre_x;
        tooLong_y = contours_c[i][0].y - pre_y;
        //X过长
        if (tooLong_x > 120)
            while (tooLong_x > 120) {
                tooLong_x -= 120;
                M.X[k] = 120 + 125;
                M.Y[k++] = 125;
            }
        else if (tooLong_x < -120)
            while (tooLong_x < -120) {
                tooLong_x += 120;
                M.X[k] = -120 + 125;
                M.Y[k++] = 125;
            }
        M.X[k] = tooLong_x + 125;
        M.Y[k++] = 125;
        //Y过长
        if (tooLong_y > 120)
            while (tooLong_y > 120) {
                tooLong_y -= 120;
                M.Y[k] = 120 + 125;
                M.X[k++] = 125;
            }
        else if (tooLong_y < -120)
            while (tooLong_y < -120) {
                tooLong_y += 120;
                M.Y[k] = -120 + 125;
                M.X[k++] = 125;
            }
        M.Y[k] = tooLong_y + 125;
        M.X[k++] = 125;

        M.X[k] = 254;
        M.Y[k++] = 254;
        for (j = SPACE; j < contours_c[i].size(); j = j + SPACE)
        {
            M.X[k] = contours_c[i][j].x - contours_c[i][j - SPACE].x + 125;
            M.Y[k++] = contours_c[i][j].y - contours_c[i][j - SPACE].y + 125;
        }
        if ((contours_c[i].size() - 1) % SPACE) {
            M.X[k] = contours_c[i][contours_c[i].size() - 1].x - contours_c[i][j - SPACE].x + 125;  //保证取到最后一个点
            M.Y[k++] = contours_c[i][contours_c[i].size() - 1].y - contours_c[i][j - SPACE].y + 125;
        }
        pre_x = contours_c[i][contours_c[i].size() - 1].x;
        pre_y = contours_c[i][contours_c[i].size() - 1].y;
        M.X[k] = 253;
        M.Y[k++] = 253;
    }
    M.X[k] = 255;
    M.Y[k++] = 255;
    M.X_Size = M.Y_Size = k;

    /// 绘出轮廓
    cv::Mat drawing(500, 500, CV_8UC3, cv::Scalar(0, 0, 0));
    for (i = 0; i < contours_c.size(); i++) //显示点
    {
        for (j = SPACE; j < contours_c[i].size(); j += SPACE)
        {
            cv::line(drawing, cv::Point((int)(contours_c[i][j].x * 500 / (double)PAINTING), (int)(contours_c[i][j].y * 500 / (double)PAINTING)), cv::Point((int)(contours_c[i][j - SPACE].x * 500 / (double)PAINTING), (int)(contours_c[i][j - SPACE].y * 500 / (double)PAINTING)), cv::Scalar(255, 255, 255), 3, cv::LINE_AA);
        }
        if ((contours_c[i].size() - 1) % SPACE)
            cv::line(drawing, cv::Point((int)(contours_c[i][contours_c[i].size() - 1].x * 500 / (double)PAINTING), (int)(contours_c[i][contours_c[i].size() - 1].y * 500 / (double)PAINTING)), cv::Point((int)(contours_c[i][j - SPACE].x * 500 / (double)PAINTING), (int)(contours_c[i][j - SPACE].y * 500 / (double)PAINTING)), cv::Scalar(255, 255, 255), 3, cv::LINE_AA);
    }
    M.Preview = drawing;
    return M;
}

@implementation OCVLetter

+(UIImage*)previewText: (NSString*) originalText font: (int)font{
    cv::Mat canny_output;
    canny_output = TextCanny(originalText.UTF8String, 100, font);
    return MatToUIImage(canny_output);
}
+(NSMutableArray*)letterResultDataX: (NSString*) originalText font: (int)font{
    cv::Mat canny_output;
    canny_output = TextCanny(originalText.UTF8String, 100, font);
    MatResult *Result = new (MatResult);
    *Result = ImgProcess(canny_output, 0);  //输入边缘效果图和形变参数，返回结果(包含最终效果图，xy移动坐标)
    NSMutableArray* XPositiong = [NSMutableArray arrayWithCapacity:10000];
    for ( int i = 0; i < 10000; ++i )
        [XPositiong addObject:[NSNumber numberWithInt:Result->X[i]]];
    return XPositiong;
}
+(NSMutableArray*)letterResultDataY: (NSString*) originalText font: (int)font{
    
    cv::Mat canny_output;
    canny_output = TextCanny(originalText.UTF8String, 100, font);
    MatResult *Result = new (MatResult);
    *Result = ImgProcess(canny_output, 0);  //输入边缘效果图和形变参数，返回结果(包含最终效果图，xy移动坐标)
    NSMutableArray* YPositiong = [NSMutableArray arrayWithCapacity:10000];
    for ( int i = 0; i < 10000; ++i )
        [YPositiong addObject:[NSNumber numberWithInt:Result->Y[i]]];
    return YPositiong;
}
@end
