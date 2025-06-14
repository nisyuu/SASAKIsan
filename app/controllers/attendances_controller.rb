class AttendancesController < ApplicationController
  before_action :logged_in_user, only: [:create, :destroy, :update, :edit]
  before_action :correct_user,   only: [:update, :edit]
  before_action :admin_user,     only: :destroy

  def create
    @attendance = current_user.today_attendance
    is_clocked_in = clock_in?(@attendance)
    is_clocked_out = clock_out?(@attendance)

    if (!is_clocked_in && !is_clocked_out) || (is_clocked_in && is_clocked_out)
      @attendance = current_user.attendances.build(clock_in_at: Time.zone.now)
      flash[:success] = "出勤しました！おはようございます！"
    elsif is_clocked_in && !is_clocked_out
      @attendance.clock_out_at = Time.zone.now
      flash[:success] = "退勤しました！おつかれさまです！"
    end
    if @attendance.save
      redirect_to root_url
    else
      @feed_items = []
      flash.clear
      render 'static_pages/home'
    end
  end

  def edit
    @attendance = Attendance.find(params[:id])
  end

  def update
    @attendance = Attendance.find(params[:id])
    if @attendance.update(attendance_params)
      flash[:success] = "勤怠を更新しました。"
      redirect_to @attendance.user
    else
      render 'edit'
    end
  end

  def destroy
    @attendance = Attendance.find(params[:id])
    @attendance.destroy
    flash[:success] = "削除しました。"
    redirect_to request.referrer || root_url
  end

  private

    def attendance_params
      params.require(:attendance).permit(:clock_in_at, :clock_out_at)
    end

    def correct_user
      @attendance = current_user.attendances.find_by(id: params[:id])
      redirect_to root_url if @attendance.nil?
    end
end
