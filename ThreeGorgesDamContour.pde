/**
 * 三峡大坝等高线图模拟
 * 使用Processing语言创建
 * 使用柏林噪声(Perlin noise)生成地形高度数据
 * 使用颜色渐变表示不同高度的等高线
 */

// 画布大小
int cols, rows;
// 地形网格大小
int scl = 10;
// 地形高度数据
float[][] terrain;
// 地形宽度和高度
int w = 1200;
int h = 900;
// 噪声缩放因子
float noiseScale = 0.1;
// 水位高度
float waterLevel = 0.4;
// 大坝位置和尺寸
int damX, damWidth;
int damY, damHeight;

void setup() {
  // 设置画布大小
  size(800, 600, P3D);
  
  // 计算网格数量
  cols = w / scl;
  rows = h / scl;
  
  // 初始化地形数组
  terrain = new float[cols][rows];
  
  // 设置大坝位置和尺寸
  damX = w / 3;
  damWidth = w / 10;
  damY = h / 2;
  damHeight = h / 4;
  
  // 生成地形数据
  generateTerrain();
}

void draw() {
  // 设置背景色
  background(0);
  
  // 设置视角
  translate(width/2, height/2);
  rotateX(PI/3);
  translate(-w/2, -h/2);
  
  // 绘制地形等高线
  drawContourMap();
  
  // 添加标题
  drawTitle();
}

// 生成地形高度数据
void generateTerrain() {
  // 使用柏林噪声生成基础地形
  float yoff = 0;
  for (int y = 0; y < rows; y++) {
    float xoff = 0;
    for (int x = 0; x < cols; x++) {
      // 基础地形
      terrain[x][y] = map(noise(xoff, yoff), 0, 1, 0, 1);
      
      // 创建河流谷地
      float riverFactor = 1.0;
      if (x > damX - damWidth*3 && x < damX + damWidth*3) {
        float distFromCenter = abs(x - damX) / (float)(damWidth*3);
        riverFactor = map(distFromCenter, 0, 1, 0.3, 1.0);
      }
      
      // 应用河流因子
      terrain[x][y] *= riverFactor;
      
      // 添加大坝
      if (x > damX - damWidth/2 && x < damX + damWidth/2 && y > damY - damHeight/2 && y < damY + damHeight/2) {
        // 大坝主体
        terrain[x][y] = 0.7;
      }
      
      // 水坝后方的水域
      if (x < damX && y > damY - damHeight && y < damY + damHeight) {
        terrain[x][y] = min(terrain[x][y], waterLevel);
      }
      
      // 水坝前方的水域（较低水位）
      if (x > damX && y > damY - damHeight && y < damY + damHeight) {
        terrain[x][y] = min(terrain[x][y], waterLevel - 0.1);
      }
      
      xoff += noiseScale;
    }
    yoff += noiseScale;
  }
}

// 绘制等高线图
void drawContourMap() {
  // 使用线条绘制等高线
  stroke(255, 255, 255, 100);
  noFill();
  
  // 绘制等高线
  for (float level = 0.1; level < 1.0; level += 0.05) {
    beginShape();
    for (int y = 0; y < rows-1; y++) {
      for (int x = 0; x < cols-1; x++) {
        if (abs(terrain[x][y] - level) < 0.01) {
          // 设置等高线颜色
          if (level < waterLevel) {
            // 水域颜色（蓝色）
            stroke(0, 100, 255, 150);
          } else if (level < 0.5) {
            // 低地颜色（绿色）
            stroke(0, 255 - int(level * 255), 0, 150);
          } else {
            // 高地颜色（棕色到白色）
            stroke(int(level * 255), int(level * 200), int(level * 100), 150);
          }
          
          // 绘制等高线点
          vertex(x * scl, y * scl, terrain[x][y] * 200);
        }
      }
    }
    endShape();
  }
  
  // 绘制地形网格
  stroke(255, 50);
  for (int y = 0; y < rows-1; y++) {
    for (int x = 0; x < cols-1; x++) {
      // 设置填充颜色
      float height = terrain[x][y];
      if (height < waterLevel) {
        // 水域颜色（蓝色）
        fill(0, 50, 200, 200);
      } else if (height < 0.5) {
        // 低地颜色（绿色）
        fill(0, 255 - int(height * 255), 0, 100);
      } else {
        // 高地颜色（棕色到白色）
        fill(int(height * 255), int(height * 200), int(height * 100), 100);
      }
      
      // 绘制地形网格
      beginShape();
      vertex(x * scl, y * scl, terrain[x][y] * 200);
      vertex(x * scl, (y+1) * scl, terrain[x][y+1] * 200);
      vertex((x+1) * scl, (y+1) * scl, terrain[x+1][y+1] * 200);
      vertex((x+1) * scl, y * scl, terrain[x+1][y] * 200);
      endShape(CLOSE);
    }
  }
}

// 绘制标题
void drawTitle() {
  // 重置变换
  camera();
  hint(DISABLE_DEPTH_TEST);
  
  // 设置文本属性
  fill(255);
  textSize(24);
  textAlign(CENTER, TOP);
  
  // 绘制标题
  text("三峡大坝等高线图模拟", width/2, 20);
  
  // 绘制说明
  textSize(14);
  text("使用Processing和柏林噪声算法生成", width/2, 50);
  
  // 恢复深度测试
  hint(ENABLE_DEPTH_TEST);
}

// 鼠标拖动可以旋转视角
void mouseDragged() {
  // 重新生成地形
  noiseScale = map(mouseX, 0, width, 0.05, 0.2);
  generateTerrain();
}

// 按键控制
void keyPressed() {
  if (key == 'r' || key == 'R') {
    // 重新生成地形
    generateTerrain();
  }
}